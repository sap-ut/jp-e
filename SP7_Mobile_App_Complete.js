// ==========================================================
// SP-7 GLASS ERP - COMPLETE MOBILE APP (REACT NATIVE)
// Author: SP-7 Technologies
// File: SP7_Mobile_App_Complete.js
// Description: Complete React Native Mobile App for Glass ERP
// ==========================================================

// ==========================================================
// 1. package.json
// ==========================================================

/*
{
  "name": "SP7GlassERP",
  "version": "1.0.0",
  "main": "node_modules/expo/AppEntry.js",
  "scripts": {
    "start": "expo start",
    "android": "expo start --android",
    "ios": "expo start --ios",
    "web": "expo start --web"
  },
  "dependencies": {
    "expo": "~49.0.0",
    "expo-status-bar": "~1.6.0",
    "react": "18.2.0",
    "react-native": "0.72.6",
    "@react-navigation/native": "^6.1.7",
    "@react-navigation/bottom-tabs": "^6.5.8",
    "@react-navigation/stack": "^6.3.17",
    "react-native-screens": "~3.22.0",
    "react-native-safe-area-context": "4.6.3",
    "react-native-vector-icons": "^10.0.0",
    "axios": "^1.5.0",
    "async-storage": "react-native",
    "react-native-paper": "^5.10.0",
    "react-native-gesture-handler": "~2.12.0",
    "react-native-reanimated": "~3.3.0",
    "react-native-table-component": "^1.2.2",
    "react-native-chart-kit": "^6.12.0",
    "react-native-pdf": "^6.7.1",
    "react-native-fs": "^2.20.0",
    "react-native-qrcode-svg": "^6.2.0",
    "react-native-barcode-builder": "^2.0.0"
  },
  "devDependencies": {
    "@babel/core": "^7.20.0"
  },
  "private": true
}
*/

// ==========================================================
// 2. App.js - Main Application
// ==========================================================

import React, { useEffect, useState } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { createStackNavigator } from '@react-navigation/stack';
import { Provider as PaperProvider } from 'react-native-paper';
import AsyncStorage from '@react-native-async-storage/async-storage';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';

// Screens
import LoginScreen from './src/screens/LoginScreen';
import DashboardScreen from './src/screens/DashboardScreen';
import PIScreen from './src/screens/PIScreen';
import WOScreen from './src/screens/WOScreen';
import CuttingScreen from './src/screens/CuttingScreen';
import InventoryScreen from './src/screens/InventoryScreen';
import ReportScreen from './src/screens/ReportScreen';
import ProfileScreen from './src/screens/ProfileScreen';

// Context
import { AuthContext } from './src/context/AuthContext';
import { API_BASE_URL } from './src/config';

const Tab = createBottomTabNavigator();
const Stack = createStackNavigator();

function MainTabs() {
  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        tabBarIcon: ({ focused, color, size }) => {
          let iconName;
          if (route.name === 'Dashboard') {
            iconName = focused ? 'view-dashboard' : 'view-dashboard-outline';
          } else if (route.name === 'PI') {
            iconName = focused ? 'file-document' : 'file-document-outline';
          } else if (route.name === 'WO') {
            iconName = focused ? 'clipboard-list' : 'clipboard-list-outline';
          } else if (route.name === 'Cutting') {
            iconName = focused ? 'content-cut' : 'content-cut';
          } else if (route.name === 'Inventory') {
            iconName = focused ? 'package' : 'package-outline';
          } else if (route.name === 'Reports') {
            iconName = focused ? 'chart-bar' : 'chart-bar';
          }
          return <Icon name={iconName} size={size} color={color} />;
        },
        tabBarActiveTintColor: '#007AFF',
        tabBarInactiveTintColor: 'gray',
        headerStyle: {
          backgroundColor: '#007AFF',
        },
        headerTintColor: '#fff',
        headerTitleStyle: {
          fontWeight: 'bold',
        },
      })}
    >
      <Tab.Screen name="Dashboard" component={DashboardScreen} />
      <Tab.Screen name="PI" component={PIScreen} />
      <Tab.Screen name="WO" component={WOScreen} />
      <Tab.Screen name="Cutting" component={CuttingScreen} />
      <Tab.Screen name="Inventory" component={InventoryScreen} />
      <Tab.Screen name="Reports" component={ReportScreen} />
    </Tab.Navigator>
  );
}

function AppStack() {
  return (
    <Stack.Navigator>
      <Stack.Screen 
        name="Main" 
        component={MainTabs} 
        options={{ headerShown: false }}
      />
      <Stack.Screen 
        name="Profile" 
        component={ProfileScreen} 
        options={{ title: 'Profile' }}
      />
    </Stack.Navigator>
  );
}

export default function App() {
  const [isLoading, setIsLoading] = useState(true);
  const [userToken, setUserToken] = useState(null);
  const [userInfo, setUserInfo] = useState(null);

  useEffect(() => {
    loadUserData();
  }, []);

  const loadUserData = async () => {
    try {
      const token = await AsyncStorage.getItem('userToken');
      const user = await AsyncStorage.getItem('userInfo');
      if (token && user) {
        setUserToken(token);
        setUserInfo(JSON.parse(user));
      }
    } catch (error) {
      console.error('Error loading user data:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const authContext = {
    signIn: async (token, user) => {
      try {
        await AsyncStorage.setItem('userToken', token);
        await AsyncStorage.setItem('userInfo', JSON.stringify(user));
        setUserToken(token);
        setUserInfo(user);
      } catch (error) {
        console.error('Error saving user data:', error);
      }
    },
    signOut: async () => {
      try {
        await AsyncStorage.removeItem('userToken');
        await AsyncStorage.removeItem('userInfo');
        setUserToken(null);
        setUserInfo(null);
      } catch (error) {
        console.error('Error removing user data:', error);
      }
    },
    userInfo,
  };

  if (isLoading) {
    return null; // Or a loading screen
  }

  return (
    <PaperProvider>
      <AuthContext.Provider value={authContext}>
        <NavigationContainer>
          {userToken ? (
            <AppStack />
          ) : (
            <Stack.Navigator>
              <Stack.Screen 
                name="Login" 
                component={LoginScreen} 
                options={{ headerShown: false }}
              />
            </Stack.Navigator>
          )}
        </NavigationContainer>
      </AuthContext.Provider>
    </PaperProvider>
  );
}

// ==========================================================
// 3. src/config/index.js - Configuration
// ==========================================================

export const API_BASE_URL = 'http://192.168.1.100:5000/api'; // Change to your server IP

export const COLORS = {
  primary: '#007AFF',
  secondary: '#5856D6',
  success: '#4CAF50',
  danger: '#FF3B30',
  warning: '#FF9500',
  info: '#5AC8FA',
  light: '#F2F2F7',
  dark: '#1C1C1E',
  white: '#FFFFFF',
  black: '#000000',
  gray: '#8E8E93',
};

export const FONTS = {
  regular: 'System',
  medium: 'System',
  bold: 'System',
};

export const STORAGE_KEYS = {
  USER_TOKEN: '@user_token',
  USER_INFO: '@user_info',
  THEME: '@theme',
  LANGUAGE: '@language',
};

// ==========================================================
// 4. src/context/AuthContext.js - Authentication Context
// ==========================================================

import React from 'react';

export const AuthContext = React.createContext();

// ==========================================================
// 5. src/services/api.js - API Service
// ==========================================================

import axios from 'axios';
import { API_BASE_URL } from '../config';
import AsyncStorage from '@react-native-async-storage/async-storage';

const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to add token
api.interceptors.request.use(
  async (config) => {
    const token = await AsyncStorage.getItem('userToken');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor for error handling
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401) {
      // Token expired
      await AsyncStorage.removeItem('userToken');
      await AsyncStorage.removeItem('userInfo');
      // Navigate to login
    }
    return Promise.reject(error);
  }
);

export const authAPI = {
  login: (username, password) => 
    api.post('/auth/login', { username, password }),
  changePassword: (oldPassword, newPassword) =>
    api.post('/auth/change-password', { old_password: oldPassword, new_password: newPassword }),
  getProfile: () => api.get('/auth/me'),
};

export const masterAPI = {
  getCustomers: () => api.get('/masters/customers'),
  getCustomer: (id) => api.get(`/masters/customers/${id}`),
  createCustomer: (data) => api.post('/masters/customers', data),
  updateCustomer: (id, data) => api.put(`/masters/customers/${id}`, data),
  deleteCustomer: (id) => api.delete(`/masters/customers/${id}`),
  
  getItems: () => api.get('/masters/items'),
  getProcesses: () => api.get('/masters/processes'),
  getCharges: () => api.get('/masters/charges'),
  getPaymentTerms: () => api.get('/masters/payment-terms'),
  getUOM: () => api.get('/masters/uom'),
};

export const piAPI = {
  getAll: () => api.get('/pi'),
  getById: (id) => api.get(`/pi/${id}`),
  create: (data) => api.post('/pi', data),
  update: (id, data) => api.put(`/pi/${id}`, data),
  delete: (id) => api.delete(`/pi/${id}`),
  convertToWO: (id) => api.post(`/pi/${id}/convert-to-wo`),
};

export const woAPI = {
  getAll: () => api.get('/wo'),
  getById: (id) => api.get(`/wo/${id}`),
  updateStatus: (id, status) => api.put(`/wo/${id}/status`, { status }),
  updateCutQty: (detailId, qty) => api.put(`/wo/details/${detailId}/cut`, { cut_qty: qty }),
  addCuttingPlan: (data) => api.post('/wo/cutting-plan', data),
  optimizeCut: (data) => api.post('/wo/optimize-cut', data),
  approveCutting: (sessionId) => api.post(`/wo/approve-cutting/${sessionId}`),
};

export const inventoryAPI = {
  getGlassStock: () => api.get('/inventory/glass'),
  getHardwareStock: () => api.get('/inventory/hardware'),
  addStock: (data) => api.post('/inventory/stock', data),
  transferStock: (data) => api.post('/inventory/transfer', data),
};

export const reportAPI = {
  getPIReport: () => api.get('/reports/pi'),
  getWOReport: () => api.get('/reports/wo'),
  getProductionReport: () => api.get('/reports/production'),
  getRejectionReport: () => api.get('/reports/rejection'),
  getPendingBilling: () => api.get('/reports/pending-billing'),
  getSalespersonPerformance: () => api.get('/reports/salesperson'),
};

export default api;

// ==========================================================
// 6. src/screens/LoginScreen.js - Login Screen
// ==========================================================

import React, { useState, useContext } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  Image,
  KeyboardAvoidingView,
  Platform,
  ActivityIndicator,
  Alert,
  ScrollView,
} from 'react-native';
import { AuthContext } from '../context/AuthContext';
import { authAPI } from '../services/api';
import { COLORS } from '../config';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';

const LoginScreen = ({ navigation }) => {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const { signIn } = useContext(AuthContext);

  const handleLogin = async () => {
    if (!username || !password) {
      Alert.alert('Error', 'Please enter username and password');
      return;
    }

    setLoading(true);
    try {
      const response = await authAPI.login(username, password);
      await signIn(response.data.token, response.data.user);
    } catch (error) {
      Alert.alert(
        'Login Failed',
        error.response?.data?.error || 'Invalid username or password'
      );
    } finally {
      setLoading(false);
    }
  };

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <ScrollView contentContainerStyle={styles.scrollContainer}>
        <View style={styles.logoContainer}>
          <View style={styles.logo}>
            <Text style={styles.logoText}>SP-7</Text>
          </View>
          <Text style={styles.appName}>SP-7 Glass ERP</Text>
          <Text style={styles.tagline}>Glass Manufacturing ERP</Text>
        </View>

        <View style={styles.formContainer}>
          <View style={styles.inputContainer}>
            <Icon name="account" size={20} color={COLORS.gray} style={styles.inputIcon} />
            <TextInput
              style={styles.input}
              placeholder="Username"
              value={username}
              onChangeText={setUsername}
              autoCapitalize="none"
              editable={!loading}
            />
          </View>

          <View style={styles.inputContainer}>
            <Icon name="lock" size={20} color={COLORS.gray} style={styles.inputIcon} />
            <TextInput
              style={styles.input}
              placeholder="Password"
              value={password}
              onChangeText={setPassword}
              secureTextEntry={!showPassword}
              editable={!loading}
            />
            <TouchableOpacity onPress={() => setShowPassword(!showPassword)}>
              <Icon
                name={showPassword ? 'eye-off' : 'eye'}
                size={20}
                color={COLORS.gray}
              />
            </TouchableOpacity>
          </View>

          <TouchableOpacity
            style={[styles.loginButton, loading && styles.loginButtonDisabled]}
            onPress={handleLogin}
            disabled={loading}
          >
            {loading ? (
              <ActivityIndicator color={COLORS.white} />
            ) : (
              <Text style={styles.loginButtonText}>Login</Text>
            )}
          </TouchableOpacity>

          <TouchableOpacity style={styles.forgotPassword}>
            <Text style={styles.forgotPasswordText}>Forgot Password?</Text>
          </TouchableOpacity>

          <View style={styles.demoContainer}>
            <Text style={styles.demoText}>Demo Credentials:</Text>
            <Text style={styles.demoText}>Username: admin</Text>
            <Text style={styles.demoText}>Password: admin123</Text>
          </View>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.white,
  },
  scrollContainer: {
    flexGrow: 1,
    justifyContent: 'center',
    padding: 20,
  },
  logoContainer: {
    alignItems: 'center',
    marginBottom: 50,
  },
  logo: {
    width: 100,
    height: 100,
    borderRadius: 20,
    backgroundColor: COLORS.primary,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 15,
  },
  logoText: {
    fontSize: 30,
    fontWeight: 'bold',
    color: COLORS.white,
  },
  appName: {
    fontSize: 24,
    fontWeight: 'bold',
    color: COLORS.primary,
    marginBottom: 5,
  },
  tagline: {
    fontSize: 14,
    color: COLORS.gray,
  },
  formContainer: {
    width: '100%',
  },
  inputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: COLORS.gray + '40',
    borderRadius: 10,
    marginBottom: 15,
    paddingHorizontal: 15,
    backgroundColor: COLORS.light,
  },
  inputIcon: {
    marginRight: 10,
  },
  input: {
    flex: 1,
    height: 50,
    fontSize: 16,
  },
  loginButton: {
    backgroundColor: COLORS.primary,
    borderRadius: 10,
    height: 50,
    justifyContent: 'center',
    alignItems: 'center',
    marginTop: 20,
  },
  loginButtonDisabled: {
    opacity: 0.7,
  },
  loginButtonText: {
    color: COLORS.white,
    fontSize: 18,
    fontWeight: 'bold',
  },
  forgotPassword: {
    alignItems: 'center',
    marginTop: 15,
  },
  forgotPasswordText: {
    color: COLORS.primary,
    fontSize: 14,
  },
  demoContainer: {
    marginTop: 40,
    padding: 15,
    backgroundColor: COLORS.light,
    borderRadius: 10,
    alignItems: 'center',
  },
  demoText: {
    fontSize: 14,
    color: COLORS.gray,
    marginBottom: 5,
  },
});

export default LoginScreen;

// ==========================================================
// 7. src/screens/DashboardScreen.js - Dashboard
// ==========================================================

import React, { useState, useEffect, useContext } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  RefreshControl,
  TouchableOpacity,
  Dimensions,
} from 'react-native';
import { AuthContext } from '../context/AuthContext';
import { reportAPI } from '../services/api';
import { COLORS } from '../config';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import { LineChart } from 'react-native-chart-kit';

const { width } = Dimensions.get('window');

const DashboardScreen = ({ navigation }) => {
  const { userInfo } = useContext(AuthContext);
  const [refreshing, setRefreshing] = useState(false);
  const [stats, setStats] = useState({
    today_pi: 0,
    week_pi: 0,
    pending_wo: 0,
    cutting_wo: 0,
    processing_wo: 0,
    completed_wo: 0,
    pending_qty: 0,
    monthly_sales: 0,
    total_sales: 0,
  });
  const [recentPIs, setRecentPIs] = useState([]);
  const [pendingWOs, setPendingWOs] = useState([]);

  useEffect(() => {
    loadDashboardData();
  }, []);

  const loadDashboardData = async () => {
    try {
      // This would be replaced with actual API call
      // const response = await reportAPI.getDashboard();
      // setStats(response.data);
      
      // Mock data for demo
      setStats({
        today_pi: 5,
        week_pi: 28,
        pending_wo: 12,
        cutting_wo: 8,
        processing_wo: 15,
        completed_wo: 45,
        pending_qty: 1250,
        monthly_sales: 2850000,
        total_sales: 12500000,
      });

      setRecentPIs([
        { id: 1, number: 'PI/2025/0001', customer: 'ABC Glass', amount: 45000, date: '13/02/2025' },
        { id: 2, number: 'PI/2025/0002', customer: 'XYZ Windows', amount: 78000, date: '13/02/2025' },
        { id: 3, number: 'PI/2025/0003', customer: 'PQR Industries', amount: 23000, date: '12/02/2025' },
      ]);

      setPendingWOs([
        { id: 1, number: 'WO/2025/001', customer: 'ABC Glass', status: 'Cutting', delivery: '15/02/2025' },
        { id: 2, number: 'WO/2025/002', customer: 'XYZ Windows', status: 'Processing', delivery: '16/02/2025' },
        { id: 3, number: 'WO/2025/003', customer: 'PQR Industries', status: 'Pending', delivery: '17/02/2025' },
      ]);
    } catch (error) {
      console.error('Error loading dashboard:', error);
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await loadDashboardData();
    setRefreshing(false);
  };

  const StatCard = ({ title, value, icon, color }) => (
    <TouchableOpacity style={[styles.statCard, { borderLeftColor: color }]}>
      <View style={styles.statHeader}>
        <Icon name={icon} size={24} color={color} />
        <Text style={styles.statTitle}>{title}</Text>
      </View>
      <Text style={[styles.statValue, { color }]}>{value}</Text>
    </TouchableOpacity>
  );

  return (
    <ScrollView
      style={styles.container}
      refreshControl={
        <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
      }
    >
      <View style={styles.welcomeSection}>
        <Text style={styles.welcomeText}>Welcome back,</Text>
        <Text style={styles.userName}>{userInfo?.name || 'User'}</Text>
      </View>

      <View style={styles.statsGrid}>
        <StatCard
          title="Today PI"
          value={stats.today_pi}
          icon="file-document"
          color={COLORS.primary}
        />
        <StatCard
          title="Pending WO"
          value={stats.pending_wo}
          icon="clipboard-list"
          color={COLORS.warning}
        />
        <StatCard
          title="In Progress"
          value={stats.cutting_wo + stats.processing_wo}
          icon="cog"
          color={COLORS.secondary}
        />
        <StatCard
          title="Completed"
          value={stats.completed_wo}
          icon="check-circle"
          color={COLORS.success}
        />
      </View>

      <View style={styles.chartSection}>
        <Text style={styles.sectionTitle}>Weekly Production</Text>
        <LineChart
          data={{
            labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
            datasets: [{
              data: [20, 45, 28, 80, 99, 43],
            }],
          }}
          width={width - 40}
          height={200}
          chartConfig={{
            backgroundColor: COLORS.white,
            backgroundGradientFrom: COLORS.white,
            backgroundGradientTo: COLORS.white,
            decimalPlaces: 0,
            color: (opacity = 1) => `rgba(0, 122, 255, ${opacity})`,
            style: {
              borderRadius: 16,
            },
          }}
          bezier
          style={styles.chart}
        />
      </View>

      <View style={styles.recentSection}>
        <View style={styles.sectionHeader}>
          <Text style={styles.sectionTitle}>Recent PIs</Text>
          <TouchableOpacity onPress={() => navigation.navigate('PI')}>
            <Text style={styles.viewAll}>View All</Text>
          </TouchableOpacity>
        </View>
        {recentPIs.map((pi) => (
          <TouchableOpacity key={pi.id} style={styles.recentItem}>
            <View style={styles.recentItemLeft}>
              <Text style={styles.recentItemNumber}>{pi.number}</Text>
              <Text style={styles.recentItemCustomer}>{pi.customer}</Text>
            </View>
            <View style={styles.recentItemRight}>
              <Text style={styles.recentItemAmount}>₹{pi.amount.toLocaleString()}</Text>
              <Text style={styles.recentItemDate}>{pi.date}</Text>
            </View>
          </TouchableOpacity>
        ))}
      </View>

      <View style={styles.recentSection}>
        <View style={styles.sectionHeader}>
          <Text style={styles.sectionTitle}>Pending WOs</Text>
          <TouchableOpacity onPress={() => navigation.navigate('WO')}>
            <Text style={styles.viewAll}>View All</Text>
          </TouchableOpacity>
        </View>
        {pendingWOs.map((wo) => (
          <TouchableOpacity key={wo.id} style={styles.recentItem}>
            <View style={styles.recentItemLeft}>
              <Text style={styles.recentItemNumber}>{wo.number}</Text>
              <Text style={styles.recentItemCustomer}>{wo.customer}</Text>
            </View>
            <View style={styles.recentItemRight}>
              <View style={[styles.statusBadge, 
                { backgroundColor: 
                  wo.status === 'Cutting' ? COLORS.warning :
                  wo.status === 'Processing' ? COLORS.primary :
                  COLORS.gray
                }]}>
                <Text style={styles.statusText}>{wo.status}</Text>
              </View>
              <Text style={styles.recentItemDate}>Due: {wo.delivery}</Text>
            </View>
          </TouchableOpacity>
        ))}
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.light,
  },
  welcomeSection: {
    padding: 20,
    backgroundColor: COLORS.white,
  },
  welcomeText: {
    fontSize: 16,
    color: COLORS.gray,
  },
  userName: {
    fontSize: 24,
    fontWeight: 'bold',
    color: COLORS.primary,
    marginTop: 5,
  },
  statsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    padding: 10,
  },
  statCard: {
    width: '45%',
    backgroundColor: COLORS.white,
    margin: '2.5%',
    padding: 15,
    borderRadius: 10,
    borderLeftWidth: 4,
    elevation: 2,
    shadowColor: COLORS.black,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  statHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 10,
  },
  statTitle: {
    fontSize: 14,
    color: COLORS.gray,
    marginLeft: 10,
  },
  statValue: {
    fontSize: 24,
    fontWeight: 'bold',
  },
  chartSection: {
    backgroundColor: COLORS.white,
    margin: 20,
    padding: 15,
    borderRadius: 10,
    elevation: 2,
  },
  chart: {
    marginVertical: 8,
    borderRadius: 16,
  },
  recentSection: {
    backgroundColor: COLORS.white,
    margin: 20,
    marginTop: 0,
    padding: 15,
    borderRadius: 10,
    elevation: 2,
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 15,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: COLORS.dark,
  },
  viewAll: {
    color: COLORS.primary,
    fontSize: 14,
  },
  recentItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: COLORS.gray + '20',
  },
  recentItemLeft: {
    flex: 1,
  },
  recentItemRight: {
    alignItems: 'flex-end',
  },
  recentItemNumber: {
    fontSize: 16,
    fontWeight: '500',
    color: COLORS.dark,
  },
  recentItemCustomer: {
    fontSize: 14,
    color: COLORS.gray,
    marginTop: 2,
  },
  recentItemAmount: {
    fontSize: 16,
    fontWeight: 'bold',
    color: COLORS.success,
  },
  recentItemDate: {
    fontSize: 12,
    color: COLORS.gray,
    marginTop: 2,
  },
  statusBadge: {
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 4,
    marginBottom: 4,
  },
  statusText: {
    color: COLORS.white,
    fontSize: 12,
    fontWeight: '500',
  },
});

export default DashboardScreen;

// ==========================================================
// 8. src/screens/PIScreen.js - Proforma Invoice Screen
// ==========================================================

import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  TextInput,
  Modal,
  Alert,
  RefreshControl,
} from 'react-native';
import { piAPI, masterAPI } from '../services/api';
import { COLORS } from '../config';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';

const PIScreen = ({ navigation }) => {
  const [pis, setPIs] = useState([]);
  const [refreshing, setRefreshing] = useState(false);
  const [modalVisible, setModalVisible] = useState(false);
  const [customers, setCustomers] = useState([]);
  const [items, setItems] = useState([]);
  const [formData, setFormData] = useState({
    customer_id: '',
    items: [],
    subtotal: 0,
    grand_total: 0,
  });

  useEffect(() => {
    loadPIs();
    loadMasters();
  }, []);

  const loadPIs = async () => {
    try {
      const response = await piAPI.getAll();
      setPIs(response.data);
    } catch (error) {
      Alert.alert('Error', 'Failed to load PIs');
    }
  };

  const loadMasters = async () => {
    try {
      const [custRes, itemsRes] = await Promise.all([
        masterAPI.getCustomers(),
        masterAPI.getItems(),
      ]);
      setCustomers(custRes.data);
      setItems(itemsRes.data);
    } catch (error) {
      console.error('Error loading masters:', error);
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await loadPIs();
    setRefreshing(false);
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 1: return COLORS.gray; // Draft
      case 2: return COLORS.success; // Confirmed
      case 3: return COLORS.primary; // Converted
      case 4: return COLORS.danger; // Cancelled
      default: return COLORS.gray;
    }
  };

  const getStatusText = (status) => {
    switch (status) {
      case 1: return 'Draft';
      case 2: return 'Confirmed';
      case 3: return 'Converted';
      case 4: return 'Cancelled';
      default: return 'Unknown';
    }
  };

  const renderPIItem = ({ item }) => (
    <TouchableOpacity style={styles.piCard}>
      <View style={styles.piHeader}>
        <Text style={styles.piNumber}>{item.pi_number}</Text>
        <View style={[styles.statusBadge, { backgroundColor: getStatusColor(item.status) }]}>
          <Text style={styles.statusText}>{getStatusText(item.status)}</Text>
        </View>
      </View>
      
      <View style={styles.piDetails}>
        <Text style={styles.customerName}>{item.customer_name}</Text>
        <Text style={styles.piDate}>
          {new Date(item.pi_date * 1000).toLocaleDateString()}
        </Text>
      </View>

      <View style={styles.piFooter}>
        <Text style={styles.piAmount}>
          ₹{(item.grand_total / 100).toLocaleString()}
        </Text>
        <View style={styles.actionButtons}>
          <TouchableOpacity style={styles.actionButton}>
            <Icon name="eye" size={20} color={COLORS.primary} />
          </TouchableOpacity>
          <TouchableOpacity style={styles.actionButton}>
            <Icon name="file-pdf-box" size={20} color={COLORS.danger} />
          </TouchableOpacity>
          <TouchableOpacity style={styles.actionButton}>
            <Icon name="share-variant" size={20} color={COLORS.success} />
          </TouchableOpacity>
        </View>
      </View>
    </TouchableOpacity>
  );

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity
          style={styles.addButton}
          onPress={() => setModalVisible(true)}
        >
          <Icon name="plus" size={24} color={COLORS.white} />
          <Text style={styles.addButtonText}>New PI</Text>
        </TouchableOpacity>
      </View>

      <FlatList
        data={pis}
        renderItem={renderPIItem}
        keyExtractor={(item) => item.pi_id.toString()}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
        }
        contentContainerStyle={styles.list}
      />

      {/* New PI Modal */}
      <Modal
        animationType="slide"
        transparent={true}
        visible={modalVisible}
        onRequestClose={() => setModalVisible(false)}
      >
        <View style={styles.modalContainer}>
          <View style={styles.modalContent}>
            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>Create New PI</Text>
              <TouchableOpacity onPress={() => setModalVisible(false)}>
                <Icon name="close" size={24} color={COLORS.dark} />
              </TouchableOpacity>
            </View>

            <ScrollView style={styles.modalBody}>
              <Text style={styles.label}>Customer</Text>
              <TouchableOpacity style={styles.pickerButton}>
                <Text>Select Customer</Text>
                <Icon name="chevron-down" size={20} color={COLORS.gray} />
              </TouchableOpacity>

              <Text style={styles.label}>Items</Text>
              <TouchableOpacity style={styles.addItemButton}>
                <Icon name="plus-circle" size={20} color={COLORS.primary} />
                <Text style={styles.addItemText}>Add Item</Text>
              </TouchableOpacity>

              {/* Item list would go here */}

              <View style={styles.summary}>
                <View style={styles.summaryRow}>
                  <Text>Subtotal:</Text>
                  <Text>₹0.00</Text>
                </View>
                <View style={styles.summaryRow}>
                  <Text>Discount:</Text>
                  <Text>₹0.00</Text>
                </View>
                <View style={[styles.summaryRow, styles.totalRow]}>
                  <Text style={styles.totalText}>Grand Total:</Text>
                  <Text style={styles.totalText}>₹0.00</Text>
                </View>
              </View>
            </ScrollView>

            <View style={styles.modalFooter}>
              <TouchableOpacity
                style={[styles.modalButton, styles.cancelButton]}
                onPress={() => setModalVisible(false)}
              >
                <Text style={styles.cancelButtonText}>Cancel</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.modalButton, styles.saveButton]}
                onPress={() => {
                  // Save PI
                  setModalVisible(false);
                }}
              >
                <Text style={styles.saveButtonText}>Save PI</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.light,
  },
  header: {
    padding: 20,
    backgroundColor: COLORS.white,
  },
  addButton: {
    backgroundColor: COLORS.primary,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 15,
    borderRadius: 10,
  },
  addButtonText: {
    color: COLORS.white,
    fontSize: 16,
    fontWeight: 'bold',
    marginLeft: 10,
  },
  list: {
    padding: 10,
  },
  piCard: {
    backgroundColor: COLORS.white,
    padding: 15,
    marginVertical: 5,
    marginHorizontal: 10,
    borderRadius: 10,
    elevation: 2,
  },
  piHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 10,
  },
  piNumber: {
    fontSize: 16,
    fontWeight: 'bold',
    color: COLORS.primary,
  },
  statusBadge: {
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 4,
  },
  statusText: {
    color: COLORS.white,
    fontSize: 12,
    fontWeight: '500',
  },
  piDetails: {
    marginBottom: 10,
  },
  customerName: {
    fontSize: 16,
    color: COLORS.dark,
  },
  piDate: {
    fontSize: 12,
    color: COLORS.gray,
    marginTop: 2,
  },
  piFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    borderTopWidth: 1,
    borderTopColor: COLORS.gray + '20',
    paddingTop: 10,
  },
  piAmount: {
    fontSize: 18,
    fontWeight: 'bold',
    color: COLORS.success,
  },
  actionButtons: {
    flexDirection: 'row',
  },
  actionButton: {
    padding: 8,
    marginLeft: 5,
  },
  modalContainer: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.5)',
    justifyContent: 'flex-end',
  },
  modalContent: {
    backgroundColor: COLORS.white,
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    maxHeight: '90%',
  },
  modalHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 20,
    borderBottomWidth: 1,
    borderBottomColor: COLORS.gray + '20',
  },
  modalTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: COLORS.dark,
  },
  modalBody: {
    padding: 20,
  },
  label: {
    fontSize: 14,
    fontWeight: '500',
    color: COLORS.dark,
    marginBottom: 5,
  },
  pickerButton: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: COLORS.gray + '40',
    borderRadius: 8,
    padding: 12,
    marginBottom: 20,
  },
  addItemButton: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 12,
    backgroundColor: COLORS.light,
    borderRadius: 8,
    marginBottom: 20,
  },
  addItemText: {
    color: COLORS.primary,
    marginLeft: 10,
    fontSize: 14,
    fontWeight: '500',
  },
  summary: {
    backgroundColor: COLORS.light,
    padding: 15,
    borderRadius: 8,
    marginTop: 20,
  },
  summaryRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 5,
  },
  totalRow: {
    borderTopWidth: 1,
    borderTopColor: COLORS.gray + '40',
    marginTop: 5,
    paddingTop: 10,
  },
  totalText: {
    fontSize: 16,
    fontWeight: 'bold',
    color: COLORS.dark,
  },
  modalFooter: {
    flexDirection: 'row',
    padding: 20,
    borderTopWidth: 1,
    borderTopColor: COLORS.gray + '20',
  },
  modalButton: {
    flex: 1,
    padding: 15,
    borderRadius: 8,
    alignItems: 'center',
  },
  cancelButton: {
    backgroundColor: COLORS.light,
    marginRight: 10,
  },
  saveButton: {
    backgroundColor: COLORS.primary,
    marginLeft: 10,
  },
  cancelButtonText: {
    color: COLORS.dark,
    fontSize: 16,
    fontWeight: '500',
  },
  saveButtonText: {
    color: COLORS.white,
    fontSize: 16,
    fontWeight: 'bold',
  },
});

export default PIScreen;

// ==========================================================
// 9. src/screens/CuttingScreen.js - Cutting Optimizer Screen
// ==========================================================

import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  TextInput,
  Alert,
} from 'react-native';
import { COLORS } from '../config';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';

const CuttingScreen = () => {
  const [woList, setWoList] = useState([
    { id: 1, number: 'WO/2025/001', item: 'Clear Glass 8mm', size: '2140x3300', qty: 50 },
    { id: 2, number: 'WO/2025/002', item: 'Tinted Glass 5mm', size: '1800x2500', qty: 25 },
  ]);

  const [selectedWO, setSelectedWO] = useState(null);
  const [cuttingPlan, setCuttingPlan] = useState([]);
  const [jumboSize, setJumboSize] = useState({ height: 6000, width: 3300 });

  const generatePlan = () => {
    // Mock cutting plan
    const plan = [
      { sheet: 1, cuts: [
        { x: 0, y: 0, w: 2140, h: 3300 },
        { x: 2140, y: 0, w: 2140, h: 3300 },
        { x: 4280, y: 0, w: 1720, h: 3300, waste: true },
      ]},
      { sheet: 2, cuts: [
        { x: 0, y: 0, w: 2140, h: 3300 },
        { x: 2140, y: 0, w: 2140, h: 3300 },
        { x: 4280, y: 0, w: 1720, h: 3300, waste: true },
      ]},
    ];
    setCuttingPlan(plan);
  };

  const renderCuttingVisual = (sheet) => {
    const totalWidth = jumboSize.width;
    const totalHeight = jumboSize.height;

    return (
      <View style={styles.sheetContainer}>
        <Text style={styles.sheetTitle}>Sheet {sheet.sheet}</Text>
        <View style={[styles.sheetVisual, { height: 150, width: 300 }]}>
          {sheet.cuts.map((cut, idx) => (
            <View
              key={idx}
              style={[
                styles.cutPiece,
                {
                  left: (cut.x / totalWidth) * 300,
                  top: (cut.y / totalHeight) * 150,
                  width: (cut.w / totalWidth) * 300,
                  height: (cut.h / totalHeight) * 150,
                  backgroundColor: cut.waste ? COLORS.gray + '40' : COLORS.primary + '40',
                  borderColor: cut.waste ? COLORS.gray : COLORS.primary,
                },
              ]}
            >
              {!cut.waste && (
                <Text style={styles.cutText}>
                  {Math.round(cut.w)}x{Math.round(cut.h)}
                </Text>
              )}
            </View>
          ))}
        </View>
      </View>
    );
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Select Work Order</Text>
        {woList.map((wo) => (
          <TouchableOpacity
            key={wo.id}
            style={[
              styles.woItem,
              selectedWO?.id === wo.id && styles.woItemSelected,
            ]}
            onPress={() => setSelectedWO(wo)}
          >
            <View style={styles.woHeader}>
              <Text style={styles.woNumber}>{wo.number}</Text>
              <Text style={styles.woQty}>Qty: {wo.qty}</Text>
            </View>
            <Text style={styles.woItemName}>{wo.item}</Text>
            <Text style={styles.woSize}>Size: {wo.size} mm</Text>
          </TouchableOpacity>
        ))}
      </View>

      {selectedWO && (
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Jumbo Sheet Size</Text>
          <View style={styles.jumboInput}>
            <TextInput
              style={styles.input}
              value={jumboSize.height.toString()}
              onChangeText={(text) => setJumboSize({ ...jumboSize, height: parseInt(text) || 0 })}
              placeholder="Height (mm)"
              keyboardType="numeric"
            />
            <Text style={styles.inputLabel}>x</Text>
            <TextInput
              style={styles.input}
              value={jumboSize.width.toString()}
              onChangeText={(text) => setJumboSize({ ...jumboSize, width: parseInt(text) || 0 })}
              placeholder="Width (mm)"
              keyboardType="numeric"
            />
          </View>

          <TouchableOpacity style={styles.generateButton} onPress={generatePlan}>
            <Icon name="cogs" size={24} color={COLORS.white} />
            <Text style={styles.generateButtonText}>Generate Cutting Plan</Text>
          </TouchableOpacity>
        </View>
      )}

      {cuttingPlan.length > 0 && (
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Cutting Plan</Text>
          {cuttingPlan.map((sheet) => renderCuttingVisual(sheet))}

          <View style={styles.summaryCard}>
            <Text style={styles.summaryTitle}>Summary</Text>
            <View style={styles.summaryRow}>
              <Text>Total Sheets:</Text>
              <Text style={styles.summaryValue}>{cuttingPlan.length}</Text>
            </View>
            <View style={styles.summaryRow}>
              <Text>Total Pieces:</Text>
              <Text style={styles.summaryValue}>{selectedWO?.qty}</Text>
            </View>
            <View style={styles.summaryRow}>
              <Text>Wastage:</Text>
              <Text style={styles.summaryValue}>8.5%</Text>
            </View>
          </View>

          <View style={styles.actionButtons}>
            <TouchableOpacity style={[styles.actionButton, styles.approveButton]}>
              <Icon name="check" size={20} color={COLORS.white} />
              <Text style={styles.actionButtonText}>Approve Plan</Text>
            </TouchableOpacity>
            <TouchableOpacity style={[styles.actionButton, styles.rejectButton]}>
              <Icon name="close" size={20} color={COLORS.white} />
              <Text style={styles.actionButtonText}>Reject</Text>
            </TouchableOpacity>
          </View>
        </View>
      )}
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.light,
  },
  section: {
    backgroundColor: COLORS.white,
    margin: 10,
    padding: 15,
    borderRadius: 10,
    elevation: 2,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: COLORS.dark,
    marginBottom: 15,
  },
  woItem: {
    borderWidth: 1,
    borderColor: COLORS.gray + '40',
    borderRadius: 8,
    padding: 12,
    marginBottom: 10,
  },
  woItemSelected: {
    borderColor: COLORS.primary,
    borderWidth: 2,
    backgroundColor: COLORS.primary + '10',
  },
  woHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 5,
  },
  woNumber: {
    fontSize: 16,
    fontWeight: 'bold',
    color: COLORS.primary,
  },
  woQty: {
    fontSize: 14,
    color: COLORS.gray,
  },
  woItemName: {
    fontSize: 14,
    color: COLORS.dark,
    marginBottom: 3,
  },
  woSize: {
    fontSize: 12,
    color: COLORS.gray,
  },
  jumboInput: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 15,
  },
  input: {
    flex: 1,
    borderWidth: 1,
    borderColor: COLORS.gray + '40',
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
  },
  inputLabel: {
    marginHorizontal: 10,
    fontSize: 18,
    color: COLORS.gray,
  },
  generateButton: {
    backgroundColor: COLORS.primary,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 15,
    borderRadius: 8,
  },
  generateButtonText: {
    color: COLORS.white,
    fontSize: 16,
    fontWeight: 'bold',
    marginLeft: 10,
  },
  sheetContainer: {
    marginBottom: 20,
  },
  sheetTitle: {
    fontSize: 16,
    fontWeight: '500',
    marginBottom: 10,
  },
  sheetVisual: {
    backgroundColor: COLORS.light,
    position: 'relative',
    borderWidth: 1,
    borderColor: COLORS.gray,
    alignSelf: 'center',
  },
  cutPiece: {
    position: 'absolute',
    borderWidth: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  cutText: {
    fontSize: 8,
    color: COLORS.dark,
  },
  summaryCard: {
    backgroundColor: COLORS.light,
    padding: 15,
    borderRadius: 8,
    marginTop: 10,
  },
  summaryTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    marginBottom: 10,
  },
  summaryRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 5,
  },
  summaryValue: {
    fontWeight: '500',
    color: COLORS.primary,
  },
  actionButtons: {
    flexDirection: 'row',
    marginTop: 15,
  },
  actionButton: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 15,
    borderRadius: 8,
    marginHorizontal: 5,
  },
  approveButton: {
    backgroundColor: COLORS.success,
  },
  rejectButton: {
    backgroundColor: COLORS.danger,
  },
  actionButtonText: {
    color: COLORS.white,
    fontSize: 16,
    fontWeight: '500',
    marginLeft: 10,
  },
});

export default CuttingScreen;

// ==========================================================
// 10. src/screens/ProfileScreen.js - User Profile
// ==========================================================

import React, { useContext, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Alert,
  TextInput,
  ScrollView,
} from 'react-native';
import { AuthContext } from '../context/AuthContext';
import { COLORS } from '../config';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';

const ProfileScreen = ({ navigation }) => {
  const { userInfo, signOut } = useContext(AuthContext);
  const [changingPassword, setChangingPassword] = useState(false);
  const [oldPassword, setOldPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');

  const handleLogout = () => {
    Alert.alert(
      'Logout',
      'Are you sure you want to logout?',
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Logout', onPress: signOut, style: 'destructive' },
      ]
    );
  };

  const handleChangePassword = () => {
    if (!oldPassword || !newPassword || !confirmPassword) {
      Alert.alert('Error', 'Please fill all fields');
      return;
    }

    if (newPassword !== confirmPassword) {
      Alert.alert('Error', 'New passwords do not match');
      return;
    }

    if (newPassword.length < 6) {
      Alert.alert('Error', 'Password must be at least 6 characters');
      return;
    }

    // API call would go here
    Alert.alert('Success', 'Password changed successfully');
    setChangingPassword(false);
    setOldPassword('');
    setNewPassword('');
    setConfirmPassword('');
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <View style={styles.avatar}>
          <Text style={styles.avatarText}>
            {userInfo?.name?.charAt(0) || 'U'}
          </Text>
        </View>
        <Text style={styles.userName}>{userInfo?.name || 'User'}</Text>
        <Text style={styles.userRole}>
          {userInfo?.role === 1 ? 'Administrator' :
           userInfo?.role === 2 ? 'Manager' :
           userInfo?.role === 3 ? 'Supervisor' :
           userInfo?.role === 4 ? 'Operator' : 'Sales'}
        </Text>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Account Information</Text>
        
        <View style={styles.infoRow}>
          <Icon name="account" size={20} color={COLORS.gray} />
          <View style={styles.infoContent}>
            <Text style={styles.infoLabel}>Username</Text>
            <Text style={styles.infoValue}>{userInfo?.username || 'admin'}</Text>
          </View>
        </View>

        <View style={styles.infoRow}>
          <Icon name="email" size={20} color={COLORS.gray} />
          <View style={styles.infoContent}>
            <Text style={styles.infoLabel}>Email</Text>
            <Text style={styles.infoValue}>{userInfo?.email || 'user@sp7.com'}</Text>
          </View>
        </View>

        <View style={styles.infoRow}>
          <Icon name="phone" size={20} color={COLORS.gray} />
          <View style={styles.infoContent}>
            <Text style={styles.infoLabel}>Mobile</Text>
            <Text style={styles.infoValue}>+91 9876543210</Text>
          </View>
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Settings</Text>

        <TouchableOpacity
          style={styles.menuItem}
          onPress={() => setChangingPassword(!changingPassword)}
        >
          <Icon name="lock-reset" size={20} color={COLORS.primary} />
          <Text style={styles.menuText}>Change Password</Text>
          <Icon name="chevron-right" size={20} color={COLORS.gray} />
        </TouchableOpacity>

        {changingPassword && (
          <View style={styles.passwordForm}>
            <TextInput
              style={styles.input}
              placeholder="Current Password"
              value={oldPassword}
              onChangeText={setOldPassword}
              secureTextEntry
            />
            <TextInput
              style={styles.input}
              placeholder="New Password"
              value={newPassword}
              onChangeText={setNewPassword}
              secureTextEntry
            />
            <TextInput
              style={styles.input}
              placeholder="Confirm New Password"
              value={confirmPassword}
              onChangeText={setConfirmPassword}
              secureTextEntry
            />
            <TouchableOpacity
              style={styles.changePasswordButton}
              onPress={handleChangePassword}
            >
              <Text style={styles.changePasswordButtonText}>Update Password</Text>
            </TouchableOpacity>
          </View>
        )}

        <TouchableOpacity style={styles.menuItem}>
          <Icon name="bell" size={20} color={COLORS.primary} />
          <Text style={styles.menuText}>Notifications</Text>
          <Icon name="chevron-right" size={20} color={COLORS.gray} />
        </TouchableOpacity>

        <TouchableOpacity style={styles.menuItem}>
          <Icon name="theme-light-dark" size={20} color={COLORS.primary} />
          <Text style={styles.menuText}>Theme</Text>
          <Icon name="chevron-right" size={20} color={COLORS.gray} />
        </TouchableOpacity>

        <TouchableOpacity style={styles.menuItem}>
          <Icon name="translate" size={20} color={COLORS.primary} />
          <Text style={styles.menuText}>Language</Text>
          <Icon name="chevron-right" size={20} color={COLORS.gray} />
        </TouchableOpacity>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>About</Text>

        <TouchableOpacity style={styles.menuItem}>
          <Icon name="information" size={20} color={COLORS.primary} />
          <Text style={styles.menuText}>App Version</Text>
          <Text style={styles.menuValue}>1.0.0</Text>
        </TouchableOpacity>

        <TouchableOpacity style={styles.menuItem}>
          <Icon name="license" size={20} color={COLORS.primary} />
          <Text style={styles.menuText}>License</Text>
          <Icon name="chevron-right" size={20} color={COLORS.gray} />
        </TouchableOpacity>

        <TouchableOpacity style={styles.menuItem}>
          <Icon name="help-circle" size={20} color={COLORS.primary} />
          <Text style={styles.menuText}>Help & Support</Text>
          <Icon name="chevron-right" size={20} color={COLORS.gray} />
        </TouchableOpacity>
      </View>

      <TouchableOpacity style={styles.logoutButton} onPress={handleLogout}>
        <Icon name="logout" size={24} color={COLORS.white} />
        <Text style={styles.logoutText}>Logout</Text>
      </TouchableOpacity>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.light,
  },
  header: {
    backgroundColor: COLORS.white,
    alignItems: 'center',
    padding: 30,
    marginBottom: 10,
  },
  avatar: {
    width: 100,
    height: 100,
    borderRadius: 50,
    backgroundColor: COLORS.primary,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 15,
  },
  avatarText: {
    fontSize: 40,
    color: COLORS.white,
    fontWeight: 'bold',
  },
  userName: {
    fontSize: 24,
    fontWeight: 'bold',
    color: COLORS.dark,
  },
  userRole: {
    fontSize: 16,
    color: COLORS.gray,
    marginTop: 5,
  },
  section: {
    backgroundColor: COLORS.white,
    margin: 10,
    padding: 15,
    borderRadius: 10,
    elevation: 2,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: COLORS.dark,
    marginBottom: 15,
  },
  infoRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 10,
    borderBottomWidth: 1,
    borderBottomColor: COLORS.gray + '20',
  },
  infoContent: {
    marginLeft: 15,
    flex: 1,
  },
  infoLabel: {
    fontSize: 12,
    color: COLORS.gray,
  },
  infoValue: {
    fontSize: 16,
    color: COLORS.dark,
    marginTop: 2,
  },
  menuItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 15,
    borderBottomWidth: 1,
    borderBottomColor: COLORS.gray + '20',
  },
  menuText: {
    flex: 1,
    marginLeft: 15,
    fontSize: 16,
    color: COLORS.dark,
  },
  menuValue: {
    fontSize: 14,
    color: COLORS.gray,
    marginRight: 10,
  },
  passwordForm: {
    marginTop: 10,
    padding: 10,
    backgroundColor: COLORS.light,
    borderRadius: 8,
  },
  input: {
    borderWidth: 1,
    borderColor: COLORS.gray + '40',
    borderRadius: 8,
    padding: 12,
    marginBottom: 10,
    fontSize: 16,
  },
  changePasswordButton: {
    backgroundColor: COLORS.primary,
    padding: 12,
    borderRadius: 8,
    alignItems: 'center',
  },
  changePasswordButtonText: {
    color: COLORS.white,
    fontSize: 16,
    fontWeight: '500',
  },
  logoutButton: {
    backgroundColor: COLORS.danger,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 18,
    margin: 20,
    borderRadius: 10,
  },
  logoutText: {
    color: COLORS.white,
    fontSize: 18,
    fontWeight: 'bold',
    marginLeft: 10,
  },
});

export default ProfileScreen;

// ==========================================================
// MOBILE APP COMPLETE - 10 FILES
// ==========================================================