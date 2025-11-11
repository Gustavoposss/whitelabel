import { Injectable, NotFoundException } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';
import { Product, ProviderResponse } from './interfaces/product.interface';
import { ProductFilterDto } from './dto/product-filter.dto';

const BRAZILIAN_PROVIDER_URL = 'http://616d6bdb6dacbb001794ca17.mockapi.io/devnology/brazilian_provider';
const EUROPEAN_PROVIDER_URL = 'http://616d6bdb6dacbb001794ca17.mockapi.io/devnology/european_provider';

@Injectable()
export class ProductsService {
  constructor(private readonly httpService: HttpService) {}

  private normalizeToArray(data: any): any[] {
    // If it's already an array, return it
    if (Array.isArray(data)) {
      return data;
    }
    
    // If it's an object, convert it to an array
    if (typeof data === 'object' && data !== null) {
      const keys = Object.keys(data);
      
      // Check if it's an object with numeric keys (like {0: {...}, 1: {...}})
      const numericKeys = keys.filter(key => !isNaN(Number(key)));
      
      if (numericKeys.length > 0) {
        // Sort by numeric key and return as array, excluding non-numeric keys
        return numericKeys
          .sort((a, b) => Number(a) - Number(b))
          .map(key => data[key])
          .filter(item => item && typeof item === 'object');
      }
      
      // Check if it has product-like properties (id, nome, name, etc.)
      if (data.id || data.nome || data.name) {
        // It's a single product object
        return [data];
      }
      
      // If it's an object with other properties, try to extract arrays
      // Look for arrays in the object
      for (const key of keys) {
        if (Array.isArray(data[key])) {
          return data[key];
        }
      }
      
      // Last resort: return empty array if we can't figure it out
      return [];
    }
    
    return [];
  }

  private async fetchFromBrazilianProvider(): Promise<ProviderResponse[]> {
    try {
      const response = await firstValueFrom(
        this.httpService.get<any>(BRAZILIAN_PROVIDER_URL),
      );
      return this.normalizeToArray(response.data);
    } catch (error) {
      console.error('Error fetching from Brazilian provider:', error);
      return [];
    }
  }

  private async fetchFromEuropeanProvider(): Promise<ProviderResponse[]> {
    try {
      const response = await firstValueFrom(
        this.httpService.get<any>(EUROPEAN_PROVIDER_URL),
      );
      return this.normalizeToArray(response.data);
    } catch (error) {
      console.error('Error fetching from European provider:', error);
      return [];
    }
  }

  private async fetchProductByIdFromProvider(
    id: string,
    provider: 'brazilian' | 'european',
  ): Promise<ProviderResponse | null> {
    try {
      const url =
        provider === 'brazilian'
          ? `${BRAZILIAN_PROVIDER_URL}/${id}`
          : `${EUROPEAN_PROVIDER_URL}/${id}`;
      const response = await firstValueFrom(this.httpService.get<ProviderResponse>(url));
      return response.data;
    } catch (error) {
      console.error(`Error fetching product ${id} from ${provider} provider:`, error);
      return null;
    }
  }

  private transformToProduct(
    item: any,
    provider: 'brazilian' | 'european',
  ): Product | null {
    // Skip if item is null or undefined
    if (!item || typeof item !== 'object') {
      return null;
    }

    // Skip if item is an array or has array-like structure (nested objects)
    if (Array.isArray(item)) {
      return null;
    }

    // Brazilian provider uses Portuguese fields (nome, descricao, preco, categoria, imagem)
    // European provider uses English fields (name, description, price, category, image/gallery)
    // For Brazilian provider, prioritize Portuguese fields; for European, prioritize English
    let name: string | undefined;
    let description: string | undefined;
    let preco: any;
    let categoria: string | undefined;
    let imagem: string | undefined;

    if (provider === 'brazilian') {
      // Brazilian provider: prioritize Portuguese fields
      name = item.nome || item.name;
      description = item.descricao || item.description;
      preco = item.preco || item.price;
      categoria = item.categoria || item.category;
      imagem = item.imagem || item.image;
    } else {
      // European provider: use English fields
      name = item.name || item.nome;
      description = item.description || item.descricao;
      preco = item.price || item.preco;
      categoria = item.category || item.categoria;
      imagem = item.image || item.imagem;
    }

    // Validate required fields
    if (!name || !item.id) {
      return null;
    }

    // Handle price - can be string or number
    let priceValue = 0;
    if (typeof preco === 'number') {
      priceValue = preco;
    } else if (typeof preco === 'string') {
      // Remove any non-numeric characters except dot and comma
      const cleanedPrice = preco.replace(/[^\d.,]/g, '').replace(',', '.');
      priceValue = parseFloat(cleanedPrice) || 0;
    }

    // Skip if price is 0 and we couldn't parse it (invalid product)
    if (priceValue === 0 && !preco) {
      return null;
    }

    // Handle image - can be 'image', 'imagem', or 'gallery' array
    let imageUrl: string | undefined = undefined;
    if (imagem && typeof imagem === 'string') {
      if (imagem.startsWith('http') || imagem.startsWith('https')) {
        imageUrl = imagem;
      }
    } else if (item.image && typeof item.image === 'string') {
      if (item.image.startsWith('http') || item.image.startsWith('https')) {
        imageUrl = item.image;
      }
    } else if (item.gallery && Array.isArray(item.gallery) && item.gallery.length > 0) {
      const firstImage = item.gallery.find((img: string) => 
        img && typeof img === 'string' && (img.startsWith('http') || img.startsWith('https'))
      );
      if (firstImage) {
        imageUrl = firstImage;
      }
    }

    // Handle category - may not exist in response
    const category = categoria || item.category || item.details?.material || item.material || undefined;

    // Get ID - can be string or number
    const id = String(item.id);

    // Build clean product object (only English fields, no duplicates from original)
    // This ensures we don't include Portuguese fields in the response
    const product: Product = {
      id,
      name: String(name),
      description: description ? String(description) : undefined,
      price: priceValue,
      category: category ? String(category) : undefined,
      image: imageUrl,
      provider,
    };

    // Add optional fields only if they exist (European provider fields)
    if (item.hasDiscount !== undefined) {
      product.hasDiscount = Boolean(item.hasDiscount);
    }
    if (item.discountValue) {
      product.discountValue = String(item.discountValue);
    }
    if (item.details && typeof item.details === 'object') {
      product.details = item.details;
    }
    if (item.gallery && Array.isArray(item.gallery)) {
      product.gallery = item.gallery;
    }
    
    // Add Brazilian provider specific fields (translated to English)
    if (item.departamento) {
      product.departamento = String(item.departamento);
    }
    if (item.material || item.details?.material) {
      product.material = String(item.material || item.details.material);
    }

    // Return only the clean product object (no spread of original item)
    return product;
  }

  private filterProducts(products: Product[], filter: ProductFilterDto): Product[] {
    let filtered = [...products];

    if (filter.provider) {
      filtered = filtered.filter((p) => p.provider === filter.provider);
    }

    if (filter.name) {
      const nameLower = filter.name.toLowerCase();
      filtered = filtered.filter((p) =>
        p.name.toLowerCase().includes(nameLower),
      );
    }

    if (filter.category) {
      filtered = filtered.filter((p) => p.category === filter.category);
    }

    if (filter.minPrice !== undefined) {
      filtered = filtered.filter((p) => p.price >= filter.minPrice!);
    }

    if (filter.maxPrice !== undefined) {
      filtered = filtered.filter((p) => p.price <= filter.maxPrice!);
    }

    return filtered;
  }

  async findAll(filter?: ProductFilterDto): Promise<Product[]> {
    const providers: ('brazilian' | 'european')[] = filter?.provider
      ? [filter.provider as 'brazilian' | 'european']
      : ['brazilian', 'european'];

    const promises = providers.map((provider) => {
      return provider === 'brazilian'
        ? this.fetchFromBrazilianProvider()
        : this.fetchFromEuropeanProvider();
    });

    const results = await Promise.all(promises);
    let allProducts: Product[] = [];

    results.forEach((products, index) => {
      const provider = providers[index];
      const transformed = products
        .map((item) => this.transformToProduct(item, provider))
        .filter((product) => product !== null && product !== undefined);
      allProducts = [...allProducts, ...transformed];
    });

    if (filter) {
      allProducts = this.filterProducts(allProducts, filter);
    }

    return allProducts;
  }

  async findOne(id: string, provider?: 'brazilian' | 'european'): Promise<Product> {
    if (provider) {
      const product = await this.fetchProductByIdFromProvider(id, provider);
      if (!product) {
        throw new NotFoundException(`Product with ID ${id} not found in ${provider} provider`);
      }
      const transformed = this.transformToProduct(product, provider);
      if (!transformed) {
        throw new NotFoundException(`Product with ID ${id} not found in ${provider} provider`);
      }
      return transformed;
    }

    // Try both providers if provider is not specified
    const [brazilianProduct, europeanProduct] = await Promise.all([
      this.fetchProductByIdFromProvider(id, 'brazilian'),
      this.fetchProductByIdFromProvider(id, 'european'),
    ]);

    if (brazilianProduct) {
      const transformed = this.transformToProduct(brazilianProduct, 'brazilian');
      if (transformed) {
        return transformed;
      }
    }

    if (europeanProduct) {
      const transformed = this.transformToProduct(europeanProduct, 'european');
      if (transformed) {
        return transformed;
      }
    }

    throw new NotFoundException(`Product with ID ${id} not found`);
  }
}

