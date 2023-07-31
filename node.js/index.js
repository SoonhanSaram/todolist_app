import express from "express";
import path from 'path';
import morgan from 'morgan';
import db from './models/index.js';

import ApiRouter from "./routes/api.js";

const app = express();
const PORT = process.env.PORT || 3001;

db.sequelize.sync({ force: false })
    .then(() => {
        console.log('데이터 베이스 연결 성공');
    })
    .catch((err) => {
        console.log(err);
    });

app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(express.static(path.join("public")));

app.use("/", ApiRouter);

app.use((req, res, next) => {
    const error = new Error(`${req.method} ${req.url} 라우터가 없습니다.`);
    error.status = 404;
    next(error);
});

app.use((err, req, res, next) => {
    res.status(err.status || 500);
    res.json({
        error: {
            message: err.message,
            stack: process.env.NODE_ENV === 'development' ? err.stack : ''
        }
    });
});

app.listen(PORT, () => {
    console.log(`${PORT}번 포트에서 대기중`);
});
