import express from "express";
import db from "../models/index.js"

const todoDB = db.models.todos;
const router = express.Router();

router.get("/", async (req, res, next) => {

    res.json(await todoDB.findAll());
})

router.post("/", async (req, res, next) => {
    console.log(req.body)
    var list;
    try {
        if (req.body.title) {
            await todoDB.create({ title: req.body.title })
            list = await todoDB.findAll();
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
        console.log(todo_num, state)
        if (todo_num && state)
            await todoDB.update({ state: state }, { where: { todo_num: todo_num } })
    } catch (error) {
        res.json({
            "title": "에러가 발생했습니다."
        })
    }

})


export default router;