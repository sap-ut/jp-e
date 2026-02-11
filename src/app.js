import React, { useState } from 'react';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import {
  Container,
  Paper,
  TextField,
  Button,
  Typography,
  Box,
  AppBar,
  Toolbar,
  IconButton,
  Drawer,
  List,
  ListItem,
  ListItemIcon,
  ListItemText,
  Grid,
  Card,
  CardContent,
  CardHeader,
  Avatar,
} from '@mui/material';
import {
  Factory as FactoryIcon,
  Dashboard as DashboardIcon,
  Inventory as InventoryIcon,
  ShoppingCart as OrdersIcon,
  LocalShipping as DispatchIcon,
  Menu as MenuIcon,
  Notifications as NotificationsIcon,
  AccountCircle as AccountIcon,
  TrendingUp,
  Inventory2,
  LocalShipping,
  AttachMoney,
} from '@mui/icons-material';

const theme = createTheme({
  palette: {
    primary: { main: '#0ea5e9' },
    secondary: { main: '#64748b' },
    background: { default: '#f8fafc' },
  },
});

function Login({ onLogin }) {
  const [email, setEmail] = useState('admin@glass.com');
  const [password, setPassword] = useState('admin123');

  const handleSubmit = (e) => {
    e.preventDefault();
    if (email && password) {
      onLogin();
    }
  };

  return (
    <Container maxWidth="xs">
      <Box sx={{ mt: 8, textAlign: 'center' }}>
        <FactoryIcon sx={{ fontSize: 70, color: 'primary.main', mb: 2 }} />
        <Typography variant="h4" sx={{ mb: 1, fontWeight: 'bold', color: 'primary.main' }}>
          🏭 Glass Line ERP
        </Typography>
        <Typography variant="body1" color="text.secondary" sx={{ mb: 4 }}>
          Complete ERP Solution for Glass Manufacturing
        </Typography>

        <Paper elevation={3} sx={{ p: 4, borderRadius: 2 }}>
          <Typography variant="h5" sx={{ mb: 3, fontWeight: 'bold' }}>
            Sign In to Dashboard
          </Typography>
          
          <form onSubmit={handleSubmit}>
            <TextField
              fullWidth
              label="Email Address"
              variant="outlined"
              margin="normal"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
            <TextField
              fullWidth
              label="Password"
              type="password"
              variant="outlined"
              margin="normal"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
            <Button
              type="submit"
              fullWidth
              variant="contained"
              size="large"
              sx={{ mt: 3, mb: 2, py: 1.5, fontSize: '1rem' }}
            >
              Sign In
            </Button>
          </form>
          
          <Typography variant="body2" color="text.secondary" align="center" sx={{ mt: 2 }}>
            Demo: admin@glass.com / admin123
          </Typography>
        </Paper>
      </Box>
    </Container>
  );
}

function Dashboard() {
  const stats = [
    { title: 'Total Orders', value: '1,247', icon: <TrendingUp />, color: '#0ea5e9' },
    { title: 'Production', value: '856', icon: <FactoryIcon />, color: '#10b981' },
    { title: 'Dispatch', value: '423', icon: <LocalShipping />, color: '#f59e0b' },
    { title: 'Revenue', value: '₹12.5L', icon: <AttachMoney />, color: '#8b5cf6' },
  ];

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" sx={{ mb: 4, fontWeight: 'bold' }}>
        Dashboard Overview
      </Typography>
      
      <Grid container spacing={3} sx={{ mb: 4 }}>
        {stats.map((stat) => (
          <Grid item xs={12} sm={6} md={3} key={stat.title}>
            <Card sx={{ borderRadius: 2 }}>
              <CardContent>
                <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                  <Avatar sx={{ bgcolor: stat.color, mr: 2 }}>
                    {stat.icon}
                  </Avatar>
                  <Box>
                    <Typography variant="h6">{stat.value}</Typography>
                    <Typography variant="body2" color="text.secondary">
                      {stat.title}
                    </Typography>
                  </Box>
                </Box>
              </CardContent>
            </Card>
          </Grid>
        ))}
      </Grid>

      <Grid container spacing={3}>
        <Grid item xs={12} md={6}>
          <Card sx={{ borderRadius: 2 }}>
            <CardHeader title="Recent Orders" />
            <CardContent>
              <List>
                {['Float Glass - 100 sheets', 'Tempered Glass - 50 units', 'Laminated Glass - 75 pieces'].map((order) => (
                  <ListItem key={order}>
                    <ListItemIcon><InventoryIcon /></ListItemIcon>
                    <ListItemText primary={order} secondary="Status: Processing" />
                  </ListItem>
                ))}
              </List>
            </CardContent>
          </Card>
        </Grid>
        
        <Grid item xs={12} md={6}>
          <Card sx={{ borderRadius: 2 }}>
            <CardHeader title="Active Dispatch" />
            <CardContent>
              <List>
                {['DL-01AB-1234 → Delhi', 'HR-38-5678 → Mumbai', 'UP-16-9012 → Bangalore'].map((dispatch) => (
                  <ListItem key={dispatch}>
                    <ListItemIcon><DispatchIcon /></ListItemIcon>
                    <ListItemText primary={dispatch} secondary="In Transit" />
                  </ListItem>
                ))}
              </List>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
}

function App() {
  const [loggedIn, setLoggedIn] = useState(false);
  const [drawerOpen, setDrawerOpen] = useState(false);

  const menuItems = [
    { text: 'Dashboard', icon: <DashboardIcon /> },
    { text: 'Products', icon: <InventoryIcon /> },
    { text: 'Orders', icon: <OrdersIcon /> },
    { text: 'Dispatch', icon: <DispatchIcon /> },
    { text: 'Production', icon: <FactoryIcon /> },
  ];

  if (!loggedIn) {
    return (
      <ThemeProvider theme={theme}>
        <CssBaseline />
        <Login onLogin={() => setLoggedIn(true)} />
      </ThemeProvider>
    );
  }

  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Box sx={{ display: 'flex' }}>
        <AppBar position="fixed" sx={{ zIndex: (theme) => theme.zIndex.drawer + 1 }}>
          <Toolbar>
            <IconButton color="inherit" onClick={() => setDrawerOpen(!drawerOpen)}>
              <MenuIcon />
            </IconButton>
            <Typography variant="h6" sx={{ flexGrow: 1 }}>
              Glass Line ERP
            </Typography>
            <IconButton color="inherit"><NotificationsIcon /></IconButton>
            <IconButton color="inherit"><AccountIcon /></IconButton>
          </Toolbar>
        </AppBar>
        
        <Drawer
          variant="persistent"
          open={drawerOpen}
          sx={{
            width: 240,
            flexShrink: 0,
            '& .MuiDrawer-paper': {
              width: 240,
              boxSizing: 'border-box',
            },
          }}
        >
          <Toolbar />
          <List>
            {menuItems.map((item) => (
              <ListItem button key={item.text}>
                <ListItemIcon>{item.icon}</ListItemIcon>
                <ListItemText primary={item.text} />
              </ListItem>
            ))}
          </List>
        </Drawer>
        
        <Box component="main" sx={{ flexGrow: 1, p: 3, mt: 8 }}>
          <Dashboard />
        </Box>
      </Box>
    </ThemeProvider>
  );
}

export default App;