import { describe, it, expect } from 'vitest';
import { PasswordService } from './password.service.js';

describe('PasswordService', () => {
  const service = new PasswordService();

  describe('hashPassword', () => {
    it('should hash a password', async () => {
      const password = 'StrongPassword123!';
      const hash = await service.hashPassword(password);

      expect(hash).not.toBe(password);
      expect(hash).toContain('$argon2id$');
    });

    it('should generate different hashes for the same password', async () => {
      const password = 'StrongPassword123!';

      const hash1 = await service.hashPassword(password);
      const hash2 = await service.hashPassword(password);

      expect(hash1).not.toBe(hash2);
    });
  });

  describe('verifyPassword', () => {
    it('should return true for a correct password', async () => {
      const password = 'StrongPassword123!';
      const hash = await service.hashPassword(password);

      await expect(service.verifyPassword(password, hash)).resolves.toBe(true);
    });

    it('should return false for an incorrect password', async () => {
      const hash = await service.hashPassword('StrongPassword123!');

      await expect(
        service.verifyPassword('WrongPassword123!', hash),
      ).resolves.toBe(false);
    });

    it('should return false for an invalid hash', async () => {
      await expect(
        service.verifyPassword('password', 'invalid-hash'),
      ).resolves.toBe(false);
    });
  });
});
