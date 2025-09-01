import mongodb, { ObjectId } from 'mongodb';

let respostas: any;

class RespostasDAO {
    static async injectDB(conn:any){
        if (respostas){
            return
        }
        try {
          respostas = await conn.db(process.env.DATABASE).collection("respostas");
        } catch (e) {
            console.error(`Não foi possível estabelecer conexão com o banco de dados de partidas ${e}`)
        }
    };

    static async postarResposta(resposta: any) {
      console.log(resposta);
        try {
            const novaResposta = await respostas.insertOne(resposta);
            
            return novaResposta;
        } catch (error) {  
            console.error(`Erro postando resposta. Erro: ${error}`)
        }
        
    };
    
    static async apagarTudo(){
        try {
            const apagarTudo = await respostas.deleteMany({});
            return apagarTudo;
        } catch (error) {
            console.error(`Erro deletando respostas. Erro: ${error}`)            
        }
    };

    static async listarTudo(){
        try {
            const listarTudo = await respostas.find({}).toArray();
            return listarTudo;
        } catch (error) {
            console.error(`Erro listando respostas. Erro: ${error}`)            
        }
    };

    static async pesquisar(valorPesquisa: any) {
        try {
            const resultadoPesquisa = await respostas.find({ mensagem: { $regex: valorPesquisa, $options: "i" } }).toArray();
            return resultadoPesquisa;
        } catch (error) {
            console.error(`Erro pesquisando respostas. Erro: ${error}`);
        }
    };
};

export { RespostasDAO };