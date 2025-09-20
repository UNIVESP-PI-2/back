// Script de inicialização do MongoDB
// Este script é executado automaticamente quando o container MongoDB é criado pela primeira vez

// Conectar à base de dados da aplicação
// Substitua 'backend_app' pelo nome da sua base de dados (valor da variável DATABASE)
db = db.getSiblingDB('backend_app');

// Verificar se o usuário admin já existe
const existingAdmin = db.users.findOne({ email: "admin@123" });

if (!existingAdmin) {
    // Criar usuário administrador padrão
    const result = db.users.insertOne({
        email: "admin@123",
        password: "admin",
        createdAt: new Date(),
        isAdmin: true
    });
    
    if (result.acknowledged) {
        print("✅ Usuário administrador criado com sucesso!");
        print("   Email: admin@123");
        print("   Senha: admin");
    } else {
        print("❌ Erro ao criar usuário administrador");
    }
} else {
    print("ℹ️ Usuário administrador já existe - ignorando criação");
}

// Você pode adicionar outros usuários ou dados iniciais aqui se necessário
// Exemplo:
// db.users.insertOne({
//     email: "user@test.com",
//     senha: "123456",
//     createdAt: new Date(),
//     isAdmin: false
// });

print("🚀 Inicialização do banco de dados concluída!");