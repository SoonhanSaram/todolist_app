import express from "express";
import db from "../models/index.js"


const todoDB = db.models.todos;
const detailsDB = db.models.details;
const router = express.Router();

router.get("/", async (req, res, next) => {
    const nickname = req.query['nickname'];
    const todoList = await todoDB.findAll({
        where: { nickname: nickname },
        include: [{
            model: detailsDB,
            as: 'details'
        }],
    });

    res.json(todoList);
})

router.post("/", async (req, res, next) => {
    const type = req.headers['type']

    try {
        if (req.body.title && type === "false") {
            // 실행위치 확인
            console.log("실행 1")
            console.log(req.body)
            await todoDB.create({ title: req.body.title, nickname: req.body.nickname })
        }
        if (req.body.title && type === "true") {
            // 실행위치 확인
            console.log("실행 2", req.body.title)
            await todoDB.create({ title: req.body.title[0], nickname: req.body.nickname })

            // todo_num 찾기
            const todo_num = await todoDB.findAll({
                limit: 1,
                order: [['sdate', 'DESC']],
                attributes: ['todo_num'],
                where: { title: req.body.title[0], nickname: req.body.nickname }
            });

            // title 중 첫번째 title을 빼고 나머지를 detail로 넣기위해 분리
            const data = req.body.title.slice(1);
            await detailsDB.bulkCreate(data.map(title => ({ title: title, todo_num: todo_num[0].todo_num, nickname: req.body.nickname })))

        }
    } catch (error) {

    }
    const todoList = await todoDB.findAll({
        include: [{
            model: detailsDB,
            as: 'details'
        }],
    });


    console.log(todoList);

    res.status(200).json(todoList)


})

router.post("/update", async (req, res, next) => {
    const { todo_num, state } = req.body
    const database = req.headers['database']
    try {
        if (database === "todos" && todo_num && state)
            await todoDB.update({ state: state }, { where: { todo_num: todo_num } })
        if (database === "details" && todo_num && state)
            await detailsDB.update({ state: state }, { where: { details_num: todo_num } })
    } catch (error) {
        res.json({
            "title": "에러가 발생했습니다."
        })
    }

})

router.post("/delete", async (req, res, next) => {
    const { todo_num } = req.body
    console.log(todo_num)
    try {
        await todoDB.destroy({ where: { todo_num: todo_num } })
        res.json(await todoDB.findAll());
    } catch (error) {

    }
})

export default router;