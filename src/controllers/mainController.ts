import { Request, Response } from "express";
import jwt from "jsonwebtoken";
import { UsersDAO } from "../DAO/usersDAO";
import { RespostasDAO } from "../DAO/respostasDAO";


interface RequestMiddleware extends Request {
  user?: any;
  headers: any;
}

const login = async (req: Request, res: Response) => {
  const { email, password } = req.body;
  console.log(req.body);
  if (!email || !password) {
    res.json({ msg: "Usuário ou Senha não informados!" });
    return;
  }

  const dadosUsuario = await UsersDAO.getUser(email);

  //Se o usuário não existe
  if (!dadosUsuario) {
    res.json({ msg: `Usuário ou senhas inválidos!` });
    return;
  }

  //Se usuário existe testa a senha e retorna
  if (dadosUsuario.password === password) {
    const date = new Date().getDate();
    const token = jwt.sign({ date, email }, process.env.JWT_SECRET as string, {
      expiresIn: "10d",
    });

    res.status(200).json({ msg: "logado", token });
  } else {
    res.status(401).json({ msg: "senha inválida" });
  }
};

const responder = async (req: RequestMiddleware, res: Response) => {
  const { nome, email, telefone, mensagem } = req.body; 
  const resposta = await RespostasDAO.postarResposta({
    nome, email, telefone, mensagem
  });
  
  if (!resposta) {
    res.status(500).json({ msg: "Erro ao enviar resposta" });
    return;
  }
  res.status(200).json({ msg: "Mensagem enviada" });
};

const teste = async (req: Request, res: Response) => {
  const data = new Date();
  res.json({ msg: `Resposta ok as: ${data}` });
};

const testeLogado = async (req: Request, res: Response) => {
  const arrayRespostas = await RespostasDAO.listarTudo();
  res.json(arrayRespostas);
};

const pesquisar = async (req: Request, res: Response) => {
  const { valorPesquisa } = req.query; // Obtém o parâmetro da query string
  if (!valorPesquisa) {
    res.status(400).json({ msg: "O parâmetro 'valorPesquisa' é obrigatório." });
    return;
  }
  console.log(valorPesquisa);
  const arrayRespostas = await RespostasDAO.pesquisar(valorPesquisa);
  res.json(arrayRespostas);
};

export { login, responder, RequestMiddleware, teste, testeLogado, pesquisar };
