import _todos from "./todos.js";
import _details from "./details.js"
const initModels = (sequelize) => {
  const todos = _todos(sequelize);
  const details = _details(sequelize);

  details.belongsTo(todos, { as: 'details_todos', foreignKey: 'todo_num', onDelete: 'cascade' })
  todos.hasMany(details, { as: 'details', foreignKey: 'todo_num', onDelete: 'cascade' })

  return {
    todos,
    details,
  };
}
export default initModels
