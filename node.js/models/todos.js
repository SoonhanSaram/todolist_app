import Sequelize from 'sequelize';
export default (sequelize) => {
  return sequelize.define(
    'todos', {
    todo_num: {
      autoIncrement: true,
      type: Sequelize.DataTypes.INTEGER,
      allowNull: false,
      primaryKey: true,
    },
    nickname: {
      type: Sequelize.DataTypes.STRING(10),
      allowNull: false,
      primaryKey: true,
    },
    title: {
      type: Sequelize.DataTypes.STRING(255),
      allowNull: false
    },
    sdate: {
      defaultValue: Sequelize.NOW,
      type: Sequelize.DataTypes.DATE,
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
    },
    state: {
      defaultValue: 0,
      type: Sequelize.DataTypes.INTEGER,
      allowNull: false,
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
