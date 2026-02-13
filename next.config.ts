/* import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  experimental: {
    ppr: true,
    clientSegmentCache: true
  }
};

export default nextConfig; */

import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  // Cette option est indispensable pour Docker
  output: 'standalone', 
  
  experimental: {
    ppr: true,
    clientSegmentCache: true
  }
};

export default nextConfig;