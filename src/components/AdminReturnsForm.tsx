import React, { useState } from 'react';
import { 
  Button, 
  TextField, 
  Typography, 
  Divider,
  Paper,
  Box
} from '@mui/material';

// Reusing the same Grid components from LoadingReturnsForm
const GridContainer: React.FC<{
  children: React.ReactNode;
  spacing?: number;
  style?: React.CSSProperties;
}> = ({ children, spacing = 3, style = {} }) => (
  <div 
    style={{
      display: 'grid',
      gridTemplateColumns: 'repeat(12, 1fr)',
      gap: spacing * 8,
      ...style
    }}
  >
    {children}
  </div>
);

const GridItem: React.FC<{
  xs?: number;
  md?: number;
  children: React.ReactNode;
  style?: React.CSSProperties;
}> = ({ xs = 12, md, children, style = {}, ...props }) => (
  <div 
    style={{
      gridColumn: `span ${xs}`,
      ...(md && { 
        '@media (min-width: 900px)': { 
          gridColumn: `span ${md}` 
        } 
      }),
      ...style
    }}
    {...props}
  >
    {children}
  </div>
);

interface ReturnsFormData {
  date: string;
  driverName: string;
  vehicleNumber: string;
  // B-Steady Returns
  returnedBSteady24x200: number;
  returnedBSteadyPieces: number;
  returnedBSteady12x200: number;
  // Jim Pombe Returns
  returnedJimPombe24x200: number;
  returnedJimPombe12x200: number;
  returnedJimPombePieces: number;
  // Additional return fields can be added here
  notes?: string;
}

const AdminReturnsForm: React.FC = () => {
  const [formData, setFormData] = useState<ReturnsFormData>({
    date: new Date().toISOString().split('T')[0],
    driverName: '',
    vehicleNumber: '',
    // B-Steady Returns
    returnedBSteady24x200: 0,
    returnedBSteadyPieces: 0,
    returnedBSteady12x200: 0,
    // Jim Pombe Returns
    returnedJimPombe24x200: 0,
    returnedJimPombe12x200: 0,
    returnedJimPombePieces: 0,
    notes: ''
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // TODO: Implement form submission logic
    console.log('Form submitted:', formData);
    // Add your API call or form handling logic here
  };

  return (
    <Paper elevation={3} sx={{ p: 3, maxWidth: 1200, margin: '0 auto' }}>
      <Typography variant="h5" gutterBottom sx={{ mb: 3 }}>
        Returns Management
      </Typography>
      
      <form onSubmit={handleSubmit}>
        <GridContainer spacing={2}>
          {/* Basic Information */}
          <GridItem xs={12} md={4}>
            <TextField
              fullWidth
              type="date"
              name="date"
              label="Date"
              value={formData.date}
              onChange={handleChange}
              variant="outlined"
              size="small"
              required
              InputLabelProps={{
                shrink: true,
              }}
            />
          </GridItem>
          
          <GridItem xs={12} md={4}>
            <TextField
              fullWidth
              name="driverName"
              label="Driver Name"
              value={formData.driverName}
              onChange={handleChange}
              variant="outlined"
              size="small"
              required
            />
          </GridItem>
          
          <GridItem xs={12} md={4}>
            <TextField
              fullWidth
              name="vehicleNumber"
              label="Vehicle Number"
              value={formData.vehicleNumber}
              onChange={handleChange}
              variant="outlined"
              size="small"
              required
            />
          </GridItem>

          {/* B-STEADY Returns Section */}
          <GridItem xs={12} style={{ marginTop: '24px' }}>
            <Typography variant="subtitle1" color="primary" sx={{ fontWeight: 'bold', fontSize: '1.1rem' }}>
              B-STEADY RETURNS
            </Typography>
            <Divider sx={{ mb: 2 }} />
          </GridItem>
          
          <GridItem xs={12} md={4}>
            <TextField
              fullWidth
              type="number"
              name="returnedBSteady24x200"
              label="24×200ml Cartons"
              value={formData.returnedBSteady24x200}
              onChange={handleChange}
              variant="outlined"
              size="small"
              inputProps={{ min: 0 }}
            />
          </GridItem>
          
          <GridItem xs={12} md={4}>
            <TextField
              fullWidth
              type="number"
              name="returnedBSteadyPieces"
              label="24×200ml Pieces"
              value={formData.returnedBSteadyPieces}
              onChange={handleChange}
              variant="outlined"
              size="small"
              inputProps={{ min: 0 }}
            />
          </GridItem>
          
          <GridItem xs={12} md={4}>
            <TextField
              fullWidth
              type="number"
              name="returnedBSteady12x200"
              label="12×200ml Cartons"
              value={formData.returnedBSteady12x200}
              onChange={handleChange}
              variant="outlined"
              size="small"
              inputProps={{ min: 0 }}
            />
          </GridItem>

          {/* JIM POMBE Returns Section */}
          <GridItem xs={12} style={{ marginTop: '24px' }}>
            <Typography variant="subtitle1" color="error" sx={{ fontWeight: 'bold', fontSize: '1.1rem' }}>
              JIM POMBE RETURNS
            </Typography>
            <Divider sx={{ mb: 2 }} />
          </GridItem>
          
          <GridItem xs={12} md={4}>
            <TextField
              fullWidth
              type="number"
              name="returnedJimPombe24x200"
              label="24×200ml Cartons"
              value={formData.returnedJimPombe24x200}
              onChange={handleChange}
              variant="outlined"
              size="small"
              inputProps={{ min: 0 }}
            />
          </GridItem>
          
          <GridItem xs={12} md={4}>
            <TextField
              fullWidth
              type="number"
              name="returnedJimPombePieces"
              label="24×200ml Pieces"
              value={formData.returnedJimPombePieces}
              onChange={handleChange}
              variant="outlined"
              size="small"
              inputProps={{ min: 0 }}
            />
          </GridItem>
          
          <GridItem xs={12} md={4}>
            <TextField
              fullWidth
              type="number"
              name="returnedJimPombe12x200"
              label="12×200ml Cartons"
              value={formData.returnedJimPombe12x200}
              onChange={handleChange}
              variant="outlined"
              size="small"
              inputProps={{ min: 0 }}
            />
          </GridItem>

          {/* Notes Section */}
          <GridItem xs={12} style={{ marginTop: '16px' }}>
            <TextField
              fullWidth
              name="notes"
              label="Additional Notes"
              value={formData.notes}
              onChange={handleChange}
              variant="outlined"
              size="small"
              multiline
              rows={3}
            />
          </GridItem>

          {/* Submit Button */}
          <GridItem xs={12} style={{ marginTop: '24px', display: 'flex', justifyContent: 'flex-end' }}>
            <Button 
              type="submit" 
              variant="contained" 
              color="primary"
              size="large"
              sx={{ minWidth: '200px' }}
            >
              Submit Returns
            </Button>
          </GridItem>
        </GridContainer>
      </form>
    </Paper>
  );
};

export default AdminReturnsForm;
