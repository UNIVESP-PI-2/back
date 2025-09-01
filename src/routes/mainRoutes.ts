import express from 'express';
import {login, responder, teste, testeLogado, pesquisar } from '../controllers/mainController'
import { authMiddleware } from '../middlewares/auth';


const router = express.Router();

router.route('/teste').get(teste);
router.route('/login').post(login);
router.route('/listartudo').get(authMiddleware,testeLogado as any);
router.route('/pesquisar').get(authMiddleware, pesquisar as any);
router.route('/responder').post(responder as any);


export {router as mainRouter};

