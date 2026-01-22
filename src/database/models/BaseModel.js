// File: backend/src/database/models/BaseModel.js
import { db } from '../../config/database.js';

export class BaseModel {
  constructor(tableName) {
    if (!tableName) throw new Error('Table name is required');
    this.tableName = tableName;
    this.db = db;
  }

  async findById(id) {
    const [rows] = await this.db.execute(
      `SELECT * FROM \`${this.tableName}\` WHERE id = ?`,
      [id]
    );
    return rows[0] || null;
  }

  async create(data) {
    const keys = Object.keys(data);
    const values = Object.values(data);
    const placeholders = keys.map(() => '?').join(', ');
    
    const [result] = await this.db.execute(
      `INSERT INTO \`${this.tableName}\` (${keys.map(k => `\`${k}\``).join(', ')}) VALUES (${placeholders})`,
      values
    );
    return result.insertId;
  }

  async update(id, data) {
    const setClause = Object.keys(data)
      .map(key => `\`${key}\` = ?`)
      .join(', ');
    const values = [...Object.values(data), id];
    
    const [result] = await this.db.execute(
      `UPDATE \`${this.tableName}\` SET ${setClause} WHERE id = ?`,
      values
    );
    return result.affectedRows;
  }

  async delete(id) {
    const [result] = await this.db.execute(
      `DELETE FROM \`${this.tableName}\` WHERE id = ?`,
      [id]
    );
    return result.affectedRows;
  }

  async findOne(conditions) {
    const whereClause = Object.keys(conditions)
      .map(key => `\`${key}\` = ?`)
      .join(' AND ');
    const values = Object.values(conditions);
    
    const [rows] = await this.db.execute(
      `SELECT * FROM \`${this.tableName}\` WHERE ${whereClause} LIMIT 1`,
      values
    );
    return rows[0] || null;
  }

  async findAll(conditions = {}, options = {}) {
    let query = `SELECT * FROM \`${this.tableName}\``;
    const values = [];
    
    if (Object.keys(conditions).length > 0) {
      const whereClause = Object.keys(conditions)
        .map(key => `\`${key}\` = ?`)
        .join(' AND ');
      query += ` WHERE ${whereClause}`;
      values.push(...Object.values(conditions));
    }
    
    if (options.limit) query += ` LIMIT ${options.limit}`;
    if (options.offset) query += ` OFFSET ${options.offset}`;
    if (options.orderBy) query += ` ORDER BY ${options.orderBy}`;
    
    const [rows] = await this.db.execute(query, values);
    return rows;
  }
}