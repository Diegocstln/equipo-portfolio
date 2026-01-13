const express = require("express");
const cors = require("cors");
const { Pool } = require("pg");

const app = express();
app.use(cors());
app.use(express.json());

// 👇 Conexión a Postgres (Docker)
const pool = new Pool({
  host: process.env.PGHOST || "db", // nombre del servicio en docker-compose
  port: Number(process.env.PGPORT || 5432),
  user: process.env.PGUSER || "vetcare_user",
  password: process.env.PGPASSWORD || "vetcare_pass",
  database: process.env.PGDATABASE || "vetcare",
});

// --- HEALTH ---
app.get("/health", async (req, res) => {
  try {
    const r = await pool.query("SELECT 1 AS ok");
    res.json({ ok: true, db: r.rows[0].ok });
  } catch (e) {
    res.status(500).json({ ok: false, error: e.message });
  }
});

// --- ENDPOINTS DE CATÁLOGOS ---
app.get("/categorias", async (req, res) => {
  try {
    const r = await pool.query(
      "SELECT id_cat, nom_cat, descripcion FROM categoria ORDER BY id_cat"
    );
    res.json(r.rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get("/especies", async (req, res) => {
  try {
    const r = await pool.query(
      "SELECT id_especie, nom_especie FROM especie ORDER BY id_especie"
    );
    res.json(r.rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});
// --- RAZAS ---
// Devuelve todas las razas o filtradas por especie: /razas?especie=1
app.get("/razas", async (req, res) => {
  try {
    const { especie } = req.query;

    let sql = "SELECT id_raza, nom_raza, id_especie FROM raza";
    const params = [];

    if (especie) {
      sql += " WHERE id_especie = $1";
      params.push(Number(especie));
    }

    sql += " ORDER BY nom_raza";
    const r = await pool.query(sql, params);
    res.json(r.rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});




app.get("/paises", async (req, res) => {
  try {
    const r = await pool.query(
      "SELECT id_pais, nom_pais FROM pais ORDER BY id_pais"
    );
    res.json(r.rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get("/laboratorios", async (req, res) => {
  try {
    const r = await pool.query(
      "SELECT id_lab, nom_lab, id_pais, telefono, email, sitio_web FROM laboratorio ORDER BY id_lab"
    );
    res.json(r.rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get("/unidades-medida", async (req, res) => {
  try {
    const r = await pool.query(
      "SELECT id_um, nom_um FROM unidad_medida ORDER BY id_um"
    );
    res.json(r.rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get("/vias-administracion", async (req, res) => {
  try {
    const r = await pool.query(
      "SELECT id_via, nom_via FROM via_administracion ORDER BY id_via"
    );
    res.json(r.rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get("/presentaciones", async (req, res) => {
  try {
    const r = await pool.query(
      "SELECT id_pres, nom_pres, descripcion FROM presentacion ORDER BY id_pres"
    );
    res.json(r.rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// --- MEDICAMENTOS (lista) ---
// (sirve para llenar el <select>)
app.get("/medicamentos", async (req, res) => {
  try {
    const r = await pool.query(
      "SELECT id_med, nom_med, id_lab, id_via, id_cat, id_especie FROM medicamento ORDER BY id_med"
    );
    res.json(r.rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// --- MEDICAMENTO (detalle por ID) ---
// (sirve para mostrar nombres de lab/cat/via/especie con JOINs)
app.get("/medicamentos/:id", async (req, res) => {
  try {
    const id = parseInt(req.params.id, 10);
    if (Number.isNaN(id)) {
      return res.status(400).json({ error: "ID inválido" });
    }

    const r = await pool.query(
      `
      SELECT
        m.id_med,
        m.nom_med,
        m.id_lab, l.nom_lab,
        m.id_via, v.nom_via,
        m.id_cat, c.nom_cat,
        m.id_especie, e.nom_especie
      FROM medicamento m
      LEFT JOIN laboratorio l ON l.id_lab = m.id_lab
      LEFT JOIN via_administracion v ON v.id_via = m.id_via
      LEFT JOIN categoria c ON c.id_cat = m.id_cat
      LEFT JOIN especie e ON e.id_especie = m.id_especie
      WHERE m.id_med = $1
      LIMIT 1
      `,
      [id]
    );

    if (r.rows.length === 0) {
      return res.status(404).json({ error: "No existe ese medicamento" });
    }

    res.json(r.rows[0]);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// 404
app.use((req, res) => res.status(404).send("Ruta no encontrada"));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log("API running on port", PORT));
