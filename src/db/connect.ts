// import mongodb from 'mongodb';
const mongodb = require('mongodb');

const connectDB = (conn:any) =>{
    const MongoClient = mongodb.MongoClient;
    
    try {
        return  MongoClient.connect(
            conn, {
            maxPoolSize: 50,
            wtimeoutMS: 2500
        });
    } catch (err: any) {
        console.error(err.stack);
        process.exit(1);
    };
    
};

export {connectDB};