import { Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import { RequestMiddleware } from '../controllers/mainController';

const authMiddleware = async (req:RequestMiddleware, res:Response, next:any) => {
    const authHeader:any  = req.headers.authorization;
    const startWith:any = process.env.HEADER_START as string + ' ';

    if(!authHeader || !authHeader.startsWith(startWith)){
        res.json({msg: "no token provided"});
        return
    }
    
    const token = authHeader.split(' ')[1];
    
    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET as string);
        const {date , email} = decoded as any;
        req.user = {date, email};
        next();
    } catch (error) {
        res.json({msg: 'token invalid'});
        return        
    }
}

export {authMiddleware}