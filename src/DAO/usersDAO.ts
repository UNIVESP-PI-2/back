let users:any;

class UsersDAO {
    static async injectDB(conn:any){
        if(users){
            return
        }
        try{
            users = await conn.db(process.env.DATABASE).collection("users");
        } catch (e) {
            console.error(`Não foi possível estabelecer conexão com o banco de dados de usuários: ${e}`)
        }
    };

    static async getUser(email:string){  
        try {
            const userObject = {
                email: email
            };
            const usuario = await users.findOne(userObject);
            return usuario
        } catch (error) {
            console.error(`Erro ao procurar username`)
        }
    };
};

export {UsersDAO};