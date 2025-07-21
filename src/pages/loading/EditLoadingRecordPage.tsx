import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Box } from '@mui/system';
import {
  Button,
  Card,
  CardContent,
  CardHeader,
  CircularProgress,
  Divider,
  TextField,
  Typography,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  IconButton,
  Snackbar,
  Alert,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  SelectChangeEvent,
} from '@mui/material';
import {
  ArrowBack as ArrowBackIcon,
  Save as SaveIcon,
  Cancel as CancelIcon,
} from '@mui/icons-material';
import { LoadingFormData, initialLoadingFormData, LoadingProduct, LoadingRecord } from '../../types/loading';

const EditLoadingRecordPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [loading, setLoading] = useState<boolean>(true);
  const [saving, setSaving] = useState<boolean>(false);
  const [snackbar, setSnackbar] = useState<{ open: boolean; message: string; severity: 'success' | 'error' }>({ 
    open: false, 
    message: '', 
    severity: 'success' 
  });
  const [formData, setFormData] = useState<LoadingFormData>(() => ({
    ...initialLoadingFormData,
    driverId: '',
    products: initialLoadingFormData.products || []
  }));

  // Fetch record data
  useEffect(() => {
    const fetchRecord = async () => {
      try {
        // Simulate API call
        await new Promise(resolve => setTimeout(resolve, 500));
        
        // Mock data - replace with actual API call
        const mockRecord: LoadingRecord = {
          id: id || '1',
          date: '2023-05-15',
          driverId: 'driver1',
          driverName: 'John Doe',
          vehicleNumber: 'KAA 123A',
          products: [
            { name: 'Bera Steady', unit: '24 x 200ml', quantity: 10 },
            { name: 'Bera Steady', unit: '12 x 200ml', quantity: 5 },
            { name: 'Jim Pombe', unit: '24 x 200ml', quantity: 8 },
          ],
          notes: 'Test loading record',
          status: 'pending',
          createdBy: 'admin',
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
        };

        setFormData({
          date: mockRecord.date,
          driverId: mockRecord.driverId,
          driverName: mockRecord.driverName,
          vehicleNumber: mockRecord.vehicleNumber,
          products: mockRecord.products,
          notes: mockRecord.notes,
        });
      } catch (error) {
        console.error('Error fetching record:', error);
        setSnackbar({
          open: true,
          message: 'Failed to load record. Please try again.',
          severity: 'error',
        });
      } finally {
        setLoading(false);
      }
    };

    if (id) {
      fetchRecord();
    } else {
      setLoading(false);
    }
  }, [id]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    
    try {
      // TODO: Replace with actual API call
      // const response = await fetch(`/api/loading/${id}`, {
      //   method: 'PUT',
      //   headers: { 'Content-Type': 'application/json' },
      //   body: JSON.stringify(formData),
      // });
      
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      setSnackbar({
        open: true,
        message: 'Record updated successfully!',
        severity: 'success',
      });
      
      // Redirect back to records list after a short delay
      setTimeout(() => {
        navigate('/loading/records');
      }, 1500);
    } catch (error) {
      console.error('Error updating record:', error);
      setSnackbar({
        open: true,
        message: 'Failed to update record. Please try again.',
        severity: 'error',
      });
    } finally {
      setSaving(false);
    }
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value,
    }));
  };

  const handleQuantityChange = (index: number, value: string) => {
    const newProducts = [...formData.products];
    newProducts[index] = {
      ...newProducts[index],
      quantity: parseInt(value) || 0,
    };
    setFormData(prev => ({
      ...prev,
      products: newProducts,
    }));
  };

  const handleCloseSnackbar = () => {
    setSnackbar(prev => ({ ...prev, open: false }));
  };

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="60vh">
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Box>
      <Box display="flex" alignItems="center" mb={3}>
        <IconButton onClick={() => navigate(-1)} sx={{ mr: 1 }}>
          <ArrowBackIcon />
        </IconButton>
        <Typography variant="h4" component="h1">
          Edit Loading Record: {id}
        </Typography>
      </Box>

      <form onSubmit={handleSubmit}>
        <Box sx={{ 
          display: 'grid',
          gridTemplateColumns: { xs: '1fr', md: '1fr 1fr' },
          gap: 3,
          width: '100%'
        }}>
          {/* Basic Information */}
          <Box>
            <Card>
              <CardHeader title="Basic Information" />
              <Divider />
              <CardContent>
                <Box sx={{ display: 'grid', gap: 2 }}>
                  <TextField
                    fullWidth
                    label="Date"
                    type="date"
                    name="date"
                    value={formData.date}
                    onChange={handleChange}
                    InputLabelProps={{
                      shrink: true,
                    }}
                    required
                  />
                  <TextField
                    fullWidth
                    label="Driver Name"
                    name="driverName"
                    value={formData.driverName}
                    onChange={handleChange}
                    required
                  />
                  <TextField
                    fullWidth
                    label="Vehicle Number"
                    name="vehicleNumber"
                    value={formData.vehicleNumber}
                    onChange={handleChange}
                    required
                  />
                </Box>
              </CardContent>
            </Card>
          </Box>

          {/* Products */}
          <Box>
            <Card>
              <CardHeader title="Products" />
              <Divider />
              <CardContent>
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
                      {formData.products.map((product: LoadingProduct, index: number) => (
                        <TableRow
                          key={`${product.name}-${product.unit}`}
                          sx={{
                            backgroundColor: product.name.includes('Bera')
                              ? 'rgba(255, 109, 0, 0.05)'
                              : 'rgba(211, 47, 47, 0.05)',
                          }}
                        >
                          <TableCell>
                            <Typography fontWeight="medium">
                              {product.name}
                            </Typography>
                          </TableCell>
                          <TableCell>{product.unit}</TableCell>
                          <TableCell align="right">
                            <TextField
                              type="number"
                              size="small"
                              value={product.quantity}
                              onChange={(e) =>
                                handleQuantityChange(index, e.target.value)
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

                <Box mt={3}>
                  <TextField
                    fullWidth
                    multiline
                    rows={3}
                    label="Notes"
                    name="notes"
                    value={formData.notes}
                    onChange={handleChange}
                    placeholder="Any additional notes or comments..."
                  />
                </Box>
              </CardContent>
            </Card>
          </Box>
          <Box sx={{ 
            gridColumn: { xs: '1 / -1', md: '1 / -1' },
            mt: 2
          }}>
            <Box sx={{ display: 'flex', justifyContent: 'flex-end', gap: 2 }}>
              <Button
                variant="outlined"
                color="primary"
                startIcon={<CancelIcon />}
                onClick={() => navigate(-1)}
              >
                Cancel
              </Button>
              <Button
                type="submit"
                variant="contained"
                color="primary"
                startIcon={<SaveIcon />}
                disabled={saving}
              >
                {saving ? 'Saving...' : 'Save Changes'}
              </Button>
            </Box>
          </Box>
        </Box>
      </form>

      <Snackbar
        open={snackbar.open}
        autoHideDuration={6000}
        onClose={handleCloseSnackbar}
        anchorOrigin={{ vertical: 'top', horizontal: 'center' }}
      >
        <Alert onClose={handleCloseSnackbar} severity={snackbar.severity} sx={{ width: '100%' }}>
          {snackbar.message}
        </Alert>
      </Snackbar>
    </Box>
  );
};

export default EditLoadingRecordPage;
