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

// --- REGISTRO DE DUEÑO ---
app.post("/auth/register", async (req, res) => {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const {
      nombre, apellidoP, apellidoM, email, contrasena,
      telefono, sexo, fechaNac, numMascotas,
      calle, numExt, numInt, codigoP, id_asen
    } = req.body;

    // 1. Insertar Cliente
    const cRes = await client.query(
      `
      INSERT INTO Cliente (correo, contrasena_cliente, cant_mascotas, edad_cliente, nombre_cliente, apellidoP_cliente, apellidoM_cliente, sexo_cliente, fech_nac_cliente)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      ON CONFLICT (contrasena_cliente) DO UPDATE SET correo = EXCLUDED.correo
      RETURNING id_cliente, nombre_cliente, correo
      `,
      [
        email,
        contrasena || Math.random().toString(36).substring(7),
        Number(numMascotas || 0),
        30,
        nombre,
        apellidoP,
        apellidoM,
        sexo || "M",
        fechaNac || new Date()
      ]
    );

    const newClient = cRes.rows[0];

    // 2. Insertar Teléfono auxiliar
    if (telefono) {
      await client.query(
        `INSERT INTO Telefonos (telefono, id_cliente) VALUES ($1, $2)`,
        [telefono, newClient.id_cliente]
      );
    }

    // 3. Domicilio
    if (calle && numExt && codigoP) {
      const dRes = await client.query(
        `
        INSERT INTO Domicilio (calle, NumExt, NumInt, codigoP, id_asen)
        VALUES ($1, $2, $3, $4, $5)
        RETURNING id_domicilio
        `,
        [
          calle,
          Number(numExt),
          numInt ? Number(numInt) : null,
          Number(codigoP),
          id_asen ? Number(id_asen) : 1
        ]
      );
      const newDom = dRes.rows[0];

      await client.query(
        `INSERT INTO Domicilio_Cliente (id_domicilio, id_cliente) VALUES ($1, $2)`,
        [newDom.id_domicilio, newClient.id_cliente]
      );
    }

    await client.query("COMMIT");
    res.status(201).json({ success: true, client: newClient });
  } catch (e) {
    await client.query("ROLLBACK");
    res.status(500).json({ error: e.message });
  } finally {
    client.release();
  }
});

// --- REGISTRO DE MASCOTA ---
app.post("/auth/register-pet", async (req, res) => {
  try {
    const {
      nombre, alto, largo, ancho, peso, sexo, fech_nac, RUAC, esterilizado, largo_pelaje, senas_parti, id_cliente, id_especie
    } = req.body;

    const r = await pool.query(
      `
      INSERT INTO Mascota (nombre, alto, largo, ancho, peso, sexo, fech_nac, RUAC, esterilizado, largo_pelaje, senas_parti, id_cliente)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
      RETURNING id_mascota, nombre
      `,
      [
        nombre,
        Number(alto || 20),
        Number(largo || 30),
        Number(ancho || 15),
        Number(peso || 5),
        sexo || "Macho",
        fech_nac || new Date(),
        RUAC || Math.random().toString(36).substring(2, 15).toUpperCase(),
        esterilizado || "Sí",
        largo_pelaje ? Number(largo_pelaje) : null,
        senas_parti || "",
        Number(id_cliente || 1)
      ]
    );

    const newPet = r.rows[0];

    if (id_especie) {
      await pool.query(
        `INSERT INTO Mascota_Especie (id_mascota, id_especie) VALUES ($1, $2) ON CONFLICT DO NOTHING`,
        [newPet.id_mascota, Number(id_especie)]
      );
    }

    res.status(201).json({ success: true, pet: newPet });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// --- OBTENER MASCOTAS DE CLIENTE ---
app.get("/clientes/:id/mascotas", async (req, res) => {
  try {
    const id = parseInt(req.params.id, 10);
    const r = await pool.query(
      `
      SELECT m.*, e.especie AS nom_especie 
      FROM Mascota m
      LEFT JOIN Mascota_Especie me ON me.id_mascota = m.id_mascota
      LEFT JOIN Especie e ON e.id_especie = me.id_especie
      WHERE m.id_cliente = $1
      ORDER BY m.id_mascota
      `,
      [id]
    );
    res.json(r.rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// --- LOGIN (CLIENTE/EMPLEADO) ---
app.post("/auth/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    const r = await pool.query(
      "SELECT id_cliente, nombre_cliente, correo FROM Cliente WHERE correo = $1 LIMIT 1",
      [email]
    );
    if (r.rows.length === 0) {
      return res.status(401).json({ error: "Credenciales incorrectas o usuario no registrado." });
    }
    res.json({ success: true, client: r.rows[0] });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// 404
app.use((req, res) => res.status(404).send("Ruta no encontrada"));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log("API running on port", PORT));
