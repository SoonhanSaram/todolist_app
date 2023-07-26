import express from "express";
import db from "../models/index.js"

const todoDB = db.models.todos;
const detailsDB = db.models.details;
const router = express.Router();

router.get("/", async (req, res, next) => {

    res.json(await todoDB.findAll());
})

router.post("/", async (req, res, next) => {
    const type = req.headers['type']
    let list;
    try {
        if (req.body.title && type === "false") {
            // 실행위치 확인
            console.log("실행 1")
            await todoDB.create({ title: req.body.title })
            list = await todoDB.findAll();

        }
        if (req.body.title && type === "true") {
            // 실행위치 확인
            console.log("실행 2", req.body.title[0])


            await todoDB.create({ title: req.body.title[0] })
            // todo_num 찾기
            const todo_num = await todoDB.findOne({ attributes: ['todo_num'] }, { where: { title: req.body.title[0] } })

            const data = req.body.title.slice(1);
            await detailsDB.bulkCreate(data.map(title => ({ title: title, todo_num: todo_num.todo_num })))
        }
    } catch (error) {

    }
    res.json(
        list
    )

})

router.post("/update", async (req, res, next) => {
    const { todo_num, state } = req.body

    try {
        if (todo_num && state)
            await todoDB.update({ state: state }, { where: { todo_num: todo_num } })
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