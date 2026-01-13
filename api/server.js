const express = require("express");
const cors = require("cors");
const { Pool } = require("pg");

const app = express();
app.use(cors());
app.use(express.json());

// 👇 Conexión a Postgres (Docker)
const pool = new Pool({
  host: process.env.PGHOST || "db",          // si tu servicio se llama distinto, lo cambiamos
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

// 404
app.use((req, res) => res.status(404).send("Ruta no encontrada"));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log("API running on port", PORT));
