export interface LoadingProduct {
  name: string;
  unit: string;
  quantity: number;
}

export interface ProductQuantity {
  productId: string;
  productName: string;
  unitId: string;
  unitName: string;
  quantity: number;
}

export interface LoadingRecord {
  id: string;
  date: string; // ISO date string
  driverId: string;
  driverName: string;
  vehicleNumber: string;
  products: LoadingProduct[];
  notes: string;
  status: 'pending' | 'completed' | 'cancelled';
  createdBy: string;
  createdAt: string; // ISO date string
  updatedAt?: string; // ISO date string
}

export interface LoadingFormData {
  date: string; // ISO date string (YYYY-MM-DD)
  driverId: string;
  driverName: string;
  vehicleNumber: string;
  products: LoadingProduct[];
  notes: string;
}

export const initialLoadingFormData: LoadingFormData = {
  date: new Date().toISOString().split('T')[0],
  driverId: '',
  driverName: '',
  vehicleNumber: '',
  products: [
    { name: 'Bera Steady', unit: '24 x 200ml', quantity: 0 },
    { name: 'Bera Steady', unit: '12 x 200ml', quantity: 0 },
    { name: 'Jim Pombe', unit: '24 x 200ml', quantity: 0 },
  ],
  notes: '',
};
