import express, { Express } from 'express';
import dotenv from 'dotenv';
import {connectDB} from './db/connect';
import cors from 'cors';
// require('express-async-errors');
import {mainRouter} from './routes/mainRoutes';
import {UsersDAO} from './DAO/usersDAO';
import {RespostasDAO} from './DAO/respostasDAO';
import 'express-async-errors';



dotenv.config();

const app: Express = express();



app.use(cors());
app.use(express.json());
app.use('/api/v1', mainRouter);


const port: string | number = process.env.PORT || 3000;
const uri: any = process.env.URI_DB;


const start = async () => {
    try {
        const client = await connectDB(uri);
        await UsersDAO.injectDB(client);
        await RespostasDAO.injectDB(client);
        if (process.env.VERCEL === undefined) {        
            app.listen(port, () => {
                console.log(`⚡️[server]: Server is running at https://localhost:${port}`);
            })
        }
    } catch (error) {
        console.log(`Not listening on port ${port}`);
        console.log(error);
    }
};

start();

export default app;




