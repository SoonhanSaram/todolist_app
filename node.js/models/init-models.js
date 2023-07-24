import _todos from "./todos.js";

const initModels = (sequelize) => {
  const todos = _todos(sequelize);
  return {
    todos,
  };
}
export default initModels
