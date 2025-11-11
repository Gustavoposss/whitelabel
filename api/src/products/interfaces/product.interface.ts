export interface Product {
  id: string;
  name: string;
  description?: string;
  price: number;
  category?: string;
  image?: string;
  provider: 'brazilian' | 'european';
  hasDiscount?: boolean;
  discountValue?: string;
  details?: any;
  gallery?: string[];
  departamento?: string;
  material?: string;
  [key: string]: any;
}

export interface ProviderResponse {
  id: string | number;
  name: string;
  description?: string;
  price: number | string;
  category?: string;
  image?: string;
  gallery?: string[];
  hasDiscount?: boolean;
  discountValue?: string;
  details?: {
    adjective?: string;
    material?: string;
    [key: string]: any;
  };
  [key: string]: any;
}

