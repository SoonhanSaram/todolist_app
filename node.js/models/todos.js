import Sequelize from 'sequelize';
export default (sequelize) => {
  return sequelize.define(
    'todos', {
    todo_num: {
      autoIncrement: true,
      type: Sequelize.DataTypes.INTEGER,
      allowNull: false,
      primaryKey: true
    },
    title: {
      type: Sequelize.DataTypes.STRING(255),
      allowNull: false
    },
    sdate: {
      type: Sequelize.DataTypes.STRING(8),
      allowNull: false
    },
    udate: {
      type: Sequelize.DataTypes.STRING(8),
      allowNull: true
    },
    cdate: {
      type: Sequelize.DataTypes.STRING(8),
      allowNull: true
    },
    detail: {
      type: Sequelize.DataTypes.INTEGER,
      allowNull: true
    }
  }, {
    sequelize,
    tableName: 'todos',
    timestamps: false,
    indexes: [
      {
        name: "PRIMARY",
        unique: true,
        using: "BTREE",
        fields: [
          { name: "todo_num" },
        ]
      },
    ]
  });
};
