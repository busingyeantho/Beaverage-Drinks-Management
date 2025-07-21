import React, { useState } from 'react';
import { 
  Box, 
  Button, 
  TextField, 
  Typography, 
  Paper, 
  FormControl, 
  InputLabel, 
  Select, 
  MenuItem, 
  SelectChangeEvent,
  Alert,
  Snackbar,
  TableContainer,
  Table,
  TableHead,
  TableBody,
  TableRow,
  TableCell
} from '@mui/material';
import { LoadingFormData, initialLoadingFormData } from '../../types/loading';

interface Driver {
  id: string;
  name: string;
}

interface Vehicle {
  id: string;
  number: string;
}

interface Product {
  id: string;
  name: string;
  units: string[];
}

// Mock data for drivers and vehicles
const drivers: Driver[] = [
  { id: 'driver1', name: 'John Doe' },
  { id: 'driver2', name: 'Jane Smith' },
  { id: 'driver3', name: 'Robert Johnson' },
  { id: 'driver4', name: 'Emily Davis' },
];

const vehicles: Vehicle[] = [
  { id: 'vehicle1', number: 'KAA 123A' },
  { id: 'vehicle2', number: 'KAB 456B' },
  { id: 'vehicle3', number: 'KAC 789C' },
  { id: 'vehicle4', number: 'KAD 012D' },
];

// Mock products data
const products: Product[] = [
  { id: 'product1', name: 'Bera Steady', units: ['24 x 200ml', '12 x 200ml'] },
  { id: 'product2', name: 'Jim Pombe', units: ['24 x 200ml'] },
];

// Generate initial form data with all products and their units
const generateInitialFormData = (): LoadingFormData => {
  const initialProducts = products.flatMap(product => 
    product.units.map(unit => ({
      name: product.name,
      unit: unit,
      quantity: 0
    }))
  );

  return {
    ...initialLoadingFormData,
    products: initialProducts,
  };
};

const LoadingForm: React.FC = () => {
  const [formData, setFormData] = useState<LoadingFormData>(generateInitialFormData());
  const [driverId, setDriverId] = useState<string>('');
  const [snackbar, setSnackbar] = useState<{ 
    open: boolean; 
    message: string; 
    severity: 'success' | 'error' 
  }>({ 
    open: false, 
    message: '', 
    severity: 'success' 
  });

  const handleDateChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData(prev => ({
      ...prev,
      date: e.target.value,
    }));
  };

  const handleDriverSelect = (event: SelectChangeEvent<string>) => {
    const selectedDriverId = event.target.value;
    setDriverId(selectedDriverId);
    
    const selectedDriver = drivers.find(d => d.id === selectedDriverId);
    if (selectedDriver) {
      setFormData(prev => ({
        ...prev,
        driverName: selectedDriver.name,
      }));
    }
  };

  const handleVehicleSelect = (event: SelectChangeEvent<string>) => {
    setFormData(prev => ({
      ...prev,
      vehicleNumber: event.target.value,
    }));
  };

  const handleQuantityChange = (productName: string, unit: string, value: string) => {
    const newProducts = formData.products.map(item => {
      if (item.name === productName && item.unit === unit) {
        return { ...item, quantity: parseInt(value) || 0 };
      }
      return item;
    });

    setFormData(prev => ({
      ...prev,
      products: newProducts,
    }));
  };

  const handleNotesChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData(prev => ({
      ...prev,
      notes: e.target.value,
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    try {
      // Validate form
      if (!driverId || !formData.vehicleNumber) {
        throw new Error('Please fill in all required fields');
      }

      // Prepare data for submission
      const submissionData = {
        ...formData,
        driverId,
        date: formData.date || new Date().toISOString().split('T')[0],
      };
      
      // TODO: Replace with actual API call
      // const response = await fetch('/api/loading', {
      //   method: 'POST',
      //   headers: { 'Content-Type': 'application/json' },
      //   body: JSON.stringify(submissionData),
      // });
      
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      setSnackbar({
        open: true,
        message: 'Loading record submitted successfully!',
        severity: 'success',
      });
      
      // Reset form
      setFormData(generateInitialFormData());
      setDriverId('');
    } catch (error) {
      console.error('Error submitting form:', error);
      setSnackbar({
        open: true,
        message: error instanceof Error ? error.message : 'Failed to submit loading record. Please try again.',
        severity: 'error',
      });
    }
  };

  const handleCloseSnackbar = () => {
    setSnackbar(prev => ({ ...prev, open: false }));
  };

  return (
    <Box component="form" onSubmit={handleSubmit} sx={{ maxWidth: 800, mx: 'auto', p: 3 }}>
      <Paper elevation={3} sx={{ p: 3 }}>
        <Typography variant="h5" component="h2" gutterBottom>
          Loading Form
        </Typography>
        
        <Box sx={{
          display: 'grid',
          gridTemplateColumns: { xs: '1fr', md: '1fr 1fr' },
          gap: 3,
          width: '100%'
        }}>
          <Box>
            <FormControl fullWidth margin="normal">
              <InputLabel id="driver-label">Driver</InputLabel>
              <Select
                labelId="driver-label"
                value={driverId}
                label="Driver"
                onChange={handleDriverSelect}
                required
              >
                {drivers.map((driver) => (
                  <MenuItem key={driver.id} value={driver.id}>
                    {driver.name}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>
          </Box>
          
          <Box>
            <FormControl fullWidth margin="normal">
              <InputLabel id="vehicle-label">Vehicle Number</InputLabel>
              <Select
                labelId="vehicle-label"
                value={formData.vehicleNumber}
                label="Vehicle Number"
                onChange={handleVehicleSelect}
                required
              >
                {vehicles.map((vehicle) => (
                  <MenuItem key={vehicle.id} value={vehicle.number}>
                    {vehicle.number}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>
          </Box>
          
          <Box sx={{ gridColumn: { xs: '1 / -1', md: '1 / -1' } }}>
            <Typography variant="h6" gutterBottom>
              Products
            </Typography>
            <TableContainer component={Paper} variant="outlined">
              <Table>
                <TableHead>
                  <TableRow>
                    <TableCell>Product</TableCell>
                    <TableCell>Unit</TableCell>
                    <TableCell align="right">Quantity</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {formData.products.map((product, index) => (
                    <TableRow
                      key={`${product.name}-${product.unit}`}
                      sx={{
                        backgroundColor: product.name.includes('Bera')
                          ? 'rgba(255, 109, 0, 0.05)'
                          : 'rgba(211, 47, 47, 0.05)',
                      }}
                    >
                      <TableCell>{product.name}</TableCell>
                      <TableCell>{product.unit}</TableCell>
                      <TableCell align="right">
                        <TextField
                          type="number"
                          size="small"
                          value={product.quantity}
                          onChange={(e) =>
                            handleQuantityChange(product.name, product.unit, e.target.value)
                          }
                          inputProps={{ min: 0 }}
                          sx={{ width: 100 }}
                        />
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>
          </Box>
          
          <Box sx={{ 
            gridColumn: { xs: '1 / -1', md: '1 / -1' },
            display: 'flex',
            justifyContent: 'flex-end',
            gap: 2,
            mt: 2
          }}>
            <Button 
              variant="outlined" 
              color="primary"
              onClick={() => {
                setFormData(generateInitialFormData());
                setDriverId('');
              }}
            >
              Reset
            </Button>
            <Button
              type="submit"
              variant="contained"
              color="primary"
              sx={{ minWidth: 120 }}
            >
              Submit
            </Button>
          </Box>
      </Box>
    </Paper>

    <Snackbar
      open={snackbar.open}
      autoHideDuration={6000}
      onClose={handleCloseSnackbar}
      anchorOrigin={{ vertical: 'top', horizontal: 'center' }}
    >
      <Alert 
        onClose={handleCloseSnackbar} 
        severity={snackbar.severity} 
        sx={{ width: '100%' }}
      >
        {snackbar.message}
      </Alert>
    </Snackbar>
  </Box>
);
};

export default LoadingForm;
