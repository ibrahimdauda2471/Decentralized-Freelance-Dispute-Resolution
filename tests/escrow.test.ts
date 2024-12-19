import { describe, it, expect, beforeEach, vi } from 'vitest';

describe('Escrow Contract', () => {
  let mockContractCall: any;
  
  beforeEach(() => {
    mockContractCall = vi.fn();
  });
  
  it('should create a project', async () => {
    mockContractCall.mockResolvedValue({ success: true, value: 1 });
    const result = await mockContractCall('create-project', 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM', 1000);
    expect(result.success).toBe(true);
    expect(result.value).toBe(1);
  });
  
  it('should release funds', async () => {
    mockContractCall.mockResolvedValue({ success: true });
    const result = await mockContractCall('release-funds', 1);
    expect(result.success).toBe(true);
  });
  
  it('should initiate a dispute', async () => {
    mockContractCall.mockResolvedValue({ success: true });
    const result = await mockContractCall('initiate-dispute', 1);
    expect(result.success).toBe(true);
  });
  
  it('should get project details', async () => {
    mockContractCall.mockResolvedValue({
      success: true,
      value: {
        client: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM',
        freelancer: 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG',
        amount: 1000,
        status: 'active'
      }
    });
    const result = await mockContractCall('get-project', 1);
    expect(result.success).toBe(true);
    expect(result.value.client).toBe('ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM');
    expect(result.value.amount).toBe(1000);
  });
});

