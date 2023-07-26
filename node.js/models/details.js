import Sequelize from 'sequelize';
export default (sequelize) => {
    return sequelize.define(
        'details', {
        details_num: {
            autoIncrement: true,
            type: Sequelize.DataTypes.INTEGER,
            allowNull: false,
            primaryKey: true
        },
        title: {
            type: Sequelize.DataTypes.STRING(255),
            allowNull: false
        },
        state: {
            defaultValue: 0,
            type: Sequelize.DataTypes.INTEGER,
            allowNull: false,
        },
        todo_num: {
            type: Sequelize.DataTypes.INTEGER,
        }
    }, {
        sequelize,
        tableName: 'details',
        timestamps: false,
        indexes: [
            {
                name: "PRIMARY",
                unique: true,
                using: "BTREE",
                fields: [
                    { name: "details_num" },
                ]
            },
        ]
    });
};
