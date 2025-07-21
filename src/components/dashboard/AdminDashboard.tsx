import React from 'react';
import { Box, Typography, Paper } from '@mui/material';
import { useAuth } from '../../context/AuthContext';
import LoadingForm from '../forms/LoadingForm';

const AdminDashboard: React.FC = () => {
  const { user } = useAuth();

  if (!user) {
    return (
      <Box p={3}>
        <Typography variant="h6">Please log in to access the dashboard</Typography>
      </Box>
    );
  }

  const renderDashboardContent = () => {
    switch (user.role) {
      case 'LOADING_ADMIN':
        return (
          <Box>
            <Typography variant="h5" gutterBottom>Loading Management</Typography>
            <Typography variant="body1" color="text.secondary" paragraph>
              Submit new loading records and manage existing ones.
            </Typography>
            <LoadingForm />
          </Box>
        );
      case 'RETURNS_ADMIN':
        return (
          <Box>
            <Typography variant="h5" gutterBottom>Returns Management Dashboard</Typography>
            <Paper sx={{ p: 3, mt: 2 }}>
              <Typography>Returns form will be displayed here</Typography>
            </Paper>
          </Box>
        );
      case 'CASHIER_MANAGER':
        return (
          <Box>
            <Typography variant="h5" gutterBottom>Sales Management Dashboard</Typography>
            <Paper sx={{ p: 3, mt: 2 }}>
              <Typography>Sales form will be displayed here</Typography>
            </Paper>
          </Box>
        );
      case 'OVERALL_ADMIN':
        return (
          <Box>
            <Typography variant="h5" gutterBottom>Admin Console</Typography>
            <Paper sx={{ p: 3, mt: 2 }}>
              <Typography>Admin approval dashboard will be displayed here</Typography>
            </Paper>
          </Box>
        );
      default:
        return (
          <Box>
            <Typography variant="h5">Welcome, {user.name}!</Typography>
            <Typography>You don't have any specific permissions assigned.</Typography>
          </Box>
        );
    }
  };

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" gutterBottom>
        {user.name}'s Dashboard
      </Typography>
      <Typography variant="subtitle1" color="text.secondary" gutterBottom>
        Role: {user.role.replace('_', ' ')}
      </Typography>
      
      {renderDashboardContent()}
      
      {/* Common dashboard widgets can go here */}
      <Box sx={{ mt: 4 }}>
        <Typography variant="h6">Quick Actions</Typography>
        {/* Add quick action buttons based on role */}
      </Box>
    </Box>
  );
};

export default AdminDashboard;
