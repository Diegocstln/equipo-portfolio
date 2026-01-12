const express = require("express");
const cors = require("cors");
const { Pool } = require("pg");

const app = express();
app.use(cors());
app.use(express.json());

const pool = new Pool({
  host: process.env.PGHOST,
  port: Number(process.env.PGPORT || 5432),
  database: process.env.PGDATABASE,
  user: process.env.PGUSER,
  password: process.env.PGPASSWORD
});

app.get("/health", async (req, res) => {
  try {
    const r = await pool.query("SELECT 1 AS ok;");
    res.json({ ok: true, db: r.rows[0].ok });
  } catch (e) {
    res.status(500).json({ ok: false, error: e.message });
  }
});

app.get("/api/catalogos/paises", async (req, res) => {
  try {
    const q = await pool.query("SELECT id_pais, nom_pais FROM pais ORDER BY id_pais;");
    res.json(q.rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get("/api/catalogos/categorias", async (req, res) => {
  try {
    const q = await pool.query("SELECT id_cat, nom_cat, descripcion FROM categoria ORDER BY id_cat;");
    res.json(q.rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get("/api/catalogos/especies", async (req, res) => {
  try {
    const q = await pool.query("SELECT id_especie, nom_especie FROM especie ORDER BY id_especie;");
    res.json(q.rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

const PORT = Number(process.env.PORT || 3000);
app.listen(PORT, () => console.log(`API on :${PORT}`));
