import { Hono } from 'npm:hono';
import { cors } from 'npm:hono/cors';
import { logger } from 'npm:hono/logger';
import { createClient } from 'npm:@supabase/supabase-js@2';
import * as kv from './kv_store.tsx';

const app = new Hono();

// Middleware
app.use('*', logger(console.log));
app.use('*', cors({
  origin: '*',
  allowHeaders: ['*'],
  allowMethods: ['*'],
}));

// Initialize Supabase client
const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
);

// Health check
app.get('/make-server-d3e0b508/health', (c) => {
  return c.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Demo reset endpoint (for testing purposes)
app.post('/make-server-d3e0b508/demo/reset', async (c) => {
  try {
    console.log('Demo reset requested - this would clear demo data in a real implementation');
    
    // In a real implementation, you might want to clear specific demo accounts
    // For now, we'll just return success
    return c.json({ 
      success: true, 
      message: 'Demo reset completed. You can now create new test accounts.' 
    });

  } catch (error) {
    console.error('Demo reset error:', error);
    return c.json({ error: 'Demo reset failed' }, 500);
  }
});

// User signup
app.post('/make-server-d3e0b508/signup', async (c) => {
  try {
    const { email, password, name, userType } = await c.req.json();

    if (!email || !password || !name || !userType) {
      return c.json({ error: 'Missing required fields: email, password, name, and userType are required' }, 400);
    }

    if (!['customer', 'cook'].includes(userType)) {
      return c.json({ error: 'Invalid userType. Must be either "customer" or "cook"' }, 400);
    }

    // Normalize and validate email
    const normalizedEmail = email.toLowerCase().trim();
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(normalizedEmail)) {
      return c.json({ error: 'Please provide a valid email address' }, 400);
    }

    // Validate password
    if (password.length < 6) {
      return c.json({ error: 'Password must be at least 6 characters long' }, 400);
    }

    // Check if user already exists in our KV store first
    const existingUsers = await kv.getByPrefix('user:');
    const userExists = existingUsers.some(u => u.email.toLowerCase() === normalizedEmail);
    
    if (userExists) {
      return c.json({ 
        error: 'A user with this email address has already been registered. Please sign in instead or use a different email address.' 
      }, 409);
    }

    console.log('Creating new user with Supabase auth:', { email: normalizedEmail, userType });

    // Create user with Supabase Auth
    const { data, error } = await supabase.auth.admin.createUser({
      email: normalizedEmail,
      password,
      user_metadata: { 
        name: name.trim(), 
        userType,
        created_at: new Date().toISOString()
      },
      // Automatically confirm the user's email since an email server hasn't been configured.
      email_confirm: true
    });

    if (error) {
      console.log('Supabase signup error:', error);
      
      // Handle specific Supabase errors
      if (error.message?.includes('User already registered') || 
          error.message?.includes('already been registered')) {
        return c.json({ 
          error: 'This email address is already registered. Please sign in instead or use a different email address.' 
        }, 409);
      } else if (error.message?.includes('Password should be at least 6 characters')) {
        return c.json({ 
          error: 'Password must be at least 6 characters long.' 
        }, 400);
      } else if (error.message?.includes('Signup requires a valid password')) {
        return c.json({ 
          error: 'Please provide a valid password (at least 6 characters).' 
        }, 400);
      } else if (error.message?.includes('Unable to validate email address')) {
        return c.json({ 
          error: 'Please provide a valid email address.' 
        }, 400);
      } else {
        return c.json({ 
          error: `Account creation failed: ${error.message}` 
        }, 400);
      }
    }

    if (!data.user) {
      return c.json({ 
        error: 'Account creation failed - no user data returned' 
      }, 500);
    }

    console.log('User created successfully:', data.user.id);

    // Store additional user data in KV store
    const userData = {
      id: data.user.id,
      email: normalizedEmail,
      name: name.trim(),
      userType,
      profile: {
        phone: '',
        address: '',
        avatar: '',
        rating: userType === 'cook' ? 5.0 : null,
        specialties: userType === 'cook' ? [] : null
      },
      created_at: new Date().toISOString()
    };

    await kv.set(`user:${data.user.id}`, userData);

    // Initialize cook-specific data
    if (userType === 'cook') {
      await kv.set(`cook:${data.user.id}:recipes`, []);
      await kv.set(`cook:${data.user.id}:stats`, {
        totalSales: 0,
        totalOrders: 0,
        rating: 5.0,
        reviewCount: 0
      });
    }

    console.log('User data stored successfully in KV store');

    return c.json({ 
      success: true, 
      message: 'Account created successfully',
      user: {
        id: data.user.id,
        email: data.user.email,
        user_metadata: data.user.user_metadata
      }
    });

  } catch (error) {
    console.error('Signup error:', error);
    return c.json({ 
      error: 'Internal server error during account creation. Please try again later.' 
    }, 500);
  }
});

// Get user profile
app.get('/make-server-d3e0b508/profile/:userId', async (c) => {
  try {
    const userId = c.req.param('userId');
    const accessToken = c.req.header('Authorization')?.split(' ')[1];

    if (!accessToken) {
      return c.json({ error: 'Authorization required' }, 401);
    }

    // Verify user
    const { data: { user }, error } = await supabase.auth.getUser(accessToken);
    if (!user?.id || error) {
      return c.json({ error: 'Unauthorized' }, 401);
    }

    const userData = await kv.get(`user:${userId}`);
    if (!userData) {
      return c.json({ error: 'User not found' }, 404);
    }

    return c.json({ user: userData });

  } catch (error) {
    console.log('Profile fetch error:', error);
    return c.json({ error: 'Internal server error while fetching profile' }, 500);
  }
});

// Get recipes (public endpoint)
app.get('/make-server-d3e0b508/recipes', async (c) => {
  try {
    const category = c.req.query('category');
    const search = c.req.query('search');

    // Get all recipe keys
    const recipeKeys = await kv.getByPrefix('recipe:');
    let recipes = recipeKeys;

    // Filter by category
    if (category && category !== 'All') {
      recipes = recipes.filter(recipe => recipe.category === category);
    }

    // Filter by search term
    if (search) {
      const searchLower = search.toLowerCase();
      recipes = recipes.filter(recipe => 
        recipe.title.toLowerCase().includes(searchLower) ||
        recipe.description.toLowerCase().includes(searchLower) ||
        recipe.cookName.toLowerCase().includes(searchLower)
      );
    }

    return c.json(recipes);

  } catch (error) {
    console.log('Recipes fetch error:', error);
    return c.json({ error: 'Internal server error while fetching recipes' }, 500);
  }
});

// Create/Update recipe (cook only)
app.post('/make-server-d3e0b508/recipes', async (c) => {
  try {
    const accessToken = c.req.header('Authorization')?.split(' ')[1];

    if (!accessToken) {
      return c.json({ error: 'Authorization required' }, 401);
    }

    // Verify cook user
    const { data: { user }, error } = await supabase.auth.getUser(accessToken);
    if (!user?.id || error) {
      return c.json({ error: 'Unauthorized' }, 401);
    }

    const userType = user.user_metadata?.userType;
    if (userType !== 'cook') {
      return c.json({ error: 'Only cooks can create recipes' }, 403);
    }

    const recipeData = await c.req.json();
    const recipeId = recipeData.id || `recipe_${Date.now()}_${user.id}`;

    const recipe = {
      id: recipeId,
      title: recipeData.title,
      description: recipeData.description,
      price: parseFloat(recipeData.price),
      category: recipeData.cuisine || recipeData.category, // Handle both field names
      prepTime: parseInt(recipeData.prepTime),
      servings: parseInt(recipeData.servings),
      ingredients: recipeData.ingredients || [],
      instructions: recipeData.instructions || [],
      image: recipeData.image || '',
      cookId: user.id,
      cookName: user.user_metadata?.name || 'Anonymous Cook',
      rating: 5.0,
      totalOrders: 0,
      available: true,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };

    await kv.set(`recipe:${recipeId}`, recipe);

    // Update cook's recipe list
    const cookRecipes = await kv.get(`cook:${user.id}:recipes`) || [];
    if (!cookRecipes.includes(recipeId)) {
      cookRecipes.push(recipeId);
      await kv.set(`cook:${user.id}:recipes`, cookRecipes);
    }

    return c.json({ success: true, recipe });

  } catch (error) {
    console.log('Recipe creation error:', error);
    return c.json({ error: 'Internal server error while creating recipe' }, 500);
  }
});

// Get cook's recipes
app.get('/make-server-d3e0b508/recipes/cook/:cookId', async (c) => {
  try {
    const cookId = c.req.param('cookId');
    const allRecipes = await kv.getByPrefix('recipe:');
    const cookRecipes = allRecipes.filter(recipe => recipe.cookId === cookId);

    return c.json(cookRecipes);

  } catch (error) {
    console.log('Cook recipes fetch error:', error);
    return c.json({ error: 'Internal server error while fetching cook recipes' }, 500);
  }
});

// Create order
app.post('/make-server-d3e0b508/orders', async (c) => {
  try {
    const accessToken = c.req.header('Authorization')?.split(' ')[1];

    if (!accessToken) {
      return c.json({ error: 'Authorization required' }, 401);
    }

    const { data: { user }, error } = await supabase.auth.getUser(accessToken);
    if (!user?.id || error) {
      return c.json({ error: 'Unauthorized' }, 401);
    }

    const orderData = await c.req.json();
    
    // Calculate total from items if not provided
    let calculatedTotal = 0;
    if (orderData.items && Array.isArray(orderData.items)) {
      for (const item of orderData.items) {
        const recipe = await kv.get(`recipe:${item.recipeId}`);
        if (recipe) {
          calculatedTotal += recipe.price * item.quantity;
        }
      }
      // Add delivery fee
      calculatedTotal += 1;
    }

    const orderId = `order_${Date.now()}_${user.id}`;

    const order = {
      id: orderId,
      customerId: user.id,
      customerName: user.user_metadata?.name || 'Customer',
      items: orderData.items,
      total: orderData.total || calculatedTotal,
      deliveryAddress: orderData.deliveryAddress,
      status: 'pending',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
      estimatedDelivery: new Date(Date.now() + 45 * 60 * 1000).toISOString() // 45 minutes
    };

    await kv.set(`order:${orderId}`, order);

    // Add to customer's orders
    const customerOrders = await kv.get(`customer:${user.id}:orders`) || [];
    customerOrders.push(orderId);
    await kv.set(`customer:${user.id}:orders`, customerOrders);

    // Add to each cook's pending orders
    for (const item of orderData.items) {
      const recipe = await kv.get(`recipe:${item.recipeId}`);
      if (recipe) {
        const cookOrders = await kv.get(`cook:${recipe.cookId}:orders`) || [];
        cookOrders.push(orderId);
        await kv.set(`cook:${recipe.cookId}:orders`, cookOrders);
      }
    }

    return c.json({ success: true, order });

  } catch (error) {
    console.log('Order creation error:', error);
    return c.json({ error: 'Internal server error while creating order' }, 500);
  }
});

// Get user's orders
app.get('/make-server-d3e0b508/orders', async (c) => {
  try {
    const accessToken = c.req.header('Authorization')?.split(' ')[1];

    if (!accessToken) {
      return c.json({ error: 'Authorization required' }, 401);
    }

    const { data: { user }, error } = await supabase.auth.getUser(accessToken);
    if (!user?.id || error) {
      return c.json({ error: 'Unauthorized' }, 401);
    }

    const userType = user.user_metadata?.userType || 'customer';
    const orderIds = await kv.get(`${userType}:${user.id}:orders`) || [];
    const orders = [];

    for (const orderId of orderIds) {
      const order = await kv.get(`order:${orderId}`);
      if (order) {
        orders.push(order);
      }
    }

    // Sort by creation date (newest first)
    orders.sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime());

    return c.json(orders);

  } catch (error) {
    console.log('Orders fetch error:', error);
    return c.json({ error: 'Internal server error while fetching orders' }, 500);
  }
});

// Update order status (cook only)
app.put('/make-server-d3e0b508/orders/:orderId/status', async (c) => {
  try {
    const accessToken = c.req.header('Authorization')?.split(' ')[1];

    if (!accessToken) {
      return c.json({ error: 'Authorization required' }, 401);
    }

    const { data: { user }, error } = await supabase.auth.getUser(accessToken);
    if (!user?.id || error) {
      return c.json({ error: 'Unauthorized' }, 401);
    }

    const orderId = c.req.param('orderId');
    const { status } = await c.req.json();

    const order = await kv.get(`order:${orderId}`);
    if (!order) {
      return c.json({ error: 'Order not found' }, 404);
    }

    const userType = user.user_metadata?.userType;
    if (userType !== 'cook') {
      return c.json({ error: 'Only cooks can update order status' }, 403);
    }

    const updatedOrder = {
      ...order,
      status,
      updated_at: new Date().toISOString()
    };

    await kv.set(`order:${orderId}`, updatedOrder);

    return c.json({ success: true, order: updatedOrder });

  } catch (error) {
    console.log('Update order status error:', error);
    return c.json({ error: 'Internal server error while updating order status' }, 500);
  }
});

// Featured cooks endpoint
app.get('/make-server-d3e0b508/featured-cooks', async (c) => {
  try {
    const allUsers = await kv.getByPrefix('user:');
    const cooks = allUsers.filter(user => user.userType === 'cook');

    // Sort by rating and total orders, take top 6
    const featuredCooks = cooks
      .sort((a, b) => {
        const aScore = (a.profile?.rating || 0) * 0.7 + (a.profile?.totalOrders || 0) * 0.3;
        const bScore = (b.profile?.rating || 0) * 0.7 + (b.profile?.totalOrders || 0) * 0.3;
        return bScore - aScore;
      })
      .slice(0, 6);

    return c.json(featuredCooks);

  } catch (error) {
    console.log('Get featured cooks error:', error);
    return c.json({ error: 'Internal server error while fetching featured cooks' }, 500);
  }
});

Deno.serve(app.fetch);