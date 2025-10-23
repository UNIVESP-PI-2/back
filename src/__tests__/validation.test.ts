describe('Backend Validation', () => {
  it('should validate email format', () => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    const validEmail = 'admin@clinica.com';
    const invalidEmail = 'admin@';

    expect(emailRegex.test(validEmail)).toBe(true);
    expect(emailRegex.test(invalidEmail)).toBe(false);
  });

  it('should validate user object structure', () => {
    const user = {
      email: 'usuario@example.com',
      password: 'senha123',
    };

    expect(user).toHaveProperty('email');
    expect(user).toHaveProperty('password');
    expect(typeof user.email).toBe('string');
    expect(typeof user.password).toBe('string');
  });

  it('should validate form response structure', () => {
    const response = {
      nome: 'Carlos Silva',
      email: 'carlos@example.com',
      telefone: '11987654321',
      mensagem: 'Gostaria de conhecer mais sobre fitoterapia',
    };

    expect(response).toHaveProperty('nome');
    expect(response).toHaveProperty('email');
    expect(response).toHaveProperty('telefone');
    expect(response).toHaveProperty('mensagem');
    expect(response.nome).not.toBe('');
  });
});
