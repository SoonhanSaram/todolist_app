import express from "express";
const router = express.Router();

router.get("/", async (req, res, next) => {
    res.json({
        "title": "오늘 할 일"
    })
})


export default router;