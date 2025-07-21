import React, { createContext, useContext, ReactNode, useState, useEffect } from 'react';
import { User, UserRole, AuthContextType } from '../types/user';

const AuthContext = createContext<AuthContextType | null>(null);

// Mock users for demonstration
const MOCK_USERS: Record<string, User> = {
  'loading@example.com': { 
    id: '1', 
    email: 'loading@example.com', 
    name: 'Loading Admin', 
    role: 'LOADING_ADMIN' 
  },
  'returns@example.com': { 
    id: '2', 
    email: 'returns@example.com', 
    name: 'Returns Admin', 
    role: 'RETURNS_ADMIN' 
  },
  'cashier@example.com': { 
    id: '3', 
    email: 'cashier@example.com', 
    name: 'Cashier Manager', 
    role: 'CASHIER_MANAGER' 
  },
  'admin@example.com': { 
    id: '4', 
    email: 'admin@example.com', 
    name: 'Overall Admin', 
    role: 'OVERALL_ADMIN' 
  },
};

export const AuthProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Check for saved user session
    const savedUser = localStorage.getItem('user');
    if (savedUser) {
      try {
        setUser(JSON.parse(savedUser));
      } catch (error) {
        console.error('Failed to parse user data', error);
        localStorage.removeItem('user');
      }
    }
    setLoading(false);
  }, []);

  const login = async (email: string, password: string) => {
    // In a real app, verify credentials with your backend
    const user = MOCK_USERS[email];
    if (user) {
      // In a real app, verify the password
      setUser(user);
      localStorage.setItem('user', JSON.stringify(user));
      return;
    }
    throw new Error('Invalid credentials');
  };

  const logout = () => {
    setUser(null);
    localStorage.removeItem('user');
  };

  const hasPermission = (requiredRole: UserRole) => {
    if (!user) return false;
    // Overall admin has all permissions
    if (user.role === 'OVERALL_ADMIN') return true;
    return user.role === requiredRole;
  };

  const roles = user ? [user.role] : [];

  const value = {
    user,
    login,
    logout,
    hasPermission,
    isLoading: loading,
    roles,
  };

  return (
    <AuthContext.Provider value={value}>
      {!loading && children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
