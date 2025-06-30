const express = require("express");
const mysql = require("mysql2");
const multer = require("multer");
const cors = require("cors");
const path = require("path");
const jwt = require("jsonwebtoken");
const fs = require("fs");
const bcrypt = require("bcryptjs");
const bodyParser = require("body-parser");

const app = express();
const PORT = 5000;
const HOST = "0.0.0.0";

const uploadsDir = path.join(__dirname, "uploads");
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir);
}

app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.json());
app.use("/uploads", express.static("uploads")); 


const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "",
  database: "fbpost",
});

db.connect((err) => {
  if (err) throw err;
  console.log("Connected to MySQL database");
});

db.query(`
  CREATE TABLE IF NOT EXISTS posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    image VARCHAR(255),
    subtext TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  );
`);

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "./uploads/");
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  },
});
const upload = multer({ storage });

const verifyToken = (req, res, next) => {
  const token = req.headers["authorization"]?.split(" ")[1];
  if (!token) return res.status(403).send("Token missing");

  jwt.verify(token, "your_secret_key", (err, decoded) => {
    if (err) return res.status(401).send("Invalid token");
    req.userId = decoded.id;
    next();
  });
};

app.post("/register", async (req, res) => {
  const { username, email, password } = req.body;
  if (!username || !email || !password)
    return res.status(400).json({ message: "All fields are required" });

  const checkQuery = "SELECT * FROM users WHERE email = ?";
  db.query(checkQuery, [email], async (err, result) => {
    if (err) return res.status(500).json({ message: "Database error" });
    if (result.length > 0)
      return res.status(409).json({ message: "Email already exists" });

    const hashedPassword = await bcrypt.hash(password, 10);
    const insertQuery =
      "INSERT INTO users (username, email, password) VALUES (?, ?, ?)";
    db.query(insertQuery, [username, email, hashedPassword], (err) => {
      if (err) return res.status(500).json({ message: "Database error" });
      res.status(201).json({ message: "User registered successfully" });
    });
  });
});

app.post("/login", (req, res) => {
  const { username, password } = req.body;
  if (!username || !password)
    return res.status(400).json({ message: "Username and password are required" });

  const query = "SELECT * FROM users WHERE username = ?";
  db.query(query, [username], async (err, result) => {
    if (err) return res.status(500).json({ message: "Database error" });
    if (result.length === 0)
      return res.status(401).json({ message: "Invalid username or password" });

    const user = result[0];
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(401).json({ message: "Invalid username or password" });

    res.json({
      message: "Login successfully.",
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
      },
    });
  });
});




app.post("/users", async (req, res) => {
  const { name, email, password } = req.body;
  if (!name || !email)
    return res.status(400).json({ message: "All fields are required" });

  const hashedPassword = password ? await bcrypt.hash(password, 10) : null;
  db.query(
    "INSERT INTO users (username, email, password) VALUES (?, ?, ?)",
    [name, email, hashedPassword || ""],
    (err, result) => {
      if (err) return res.status(500).json({ message: "Database error" });
      res.json({ message: "User added successfully", id: result.insertId });
    }
  );
});


app.get("/users", (req, res) => {
  db.query("SELECT id, username AS name, email FROM users", (err, result) => {
    if (err) return res.status(500).json({ message: "Server error" });
    res.json(result);
  });
});



app.put("/users/:id", (req, res) => {
  const { name, email } = req.body;
  if (!name || !email)
    return res.status(400).json({ message: "All fields are required" });

  db.query(
    "UPDATE users SET username = ?, email = ? WHERE id = ?",
    [name, email, req.params.id],
    (err) => {
      if (err) return res.status(500).json({ message: "Server error" });
      res.json({ message: "User updated successfully" });
    }
  );
});



app.delete("/users/:id", (req, res) => {
  db.query("DELETE FROM users WHERE id = ?", [req.params.id], (err) => {
    if (err) return res.status(500).json({ message: "Server error" });
    res.json({ message: "User deleted successfully" });
  });
});







app.post("/api/posts", upload.single("image"), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ message: "No image uploaded" });
  }

  const { subtext } = req.body;
  const image = req.file.filename;

  const query = "INSERT INTO posts (image, subtext) VALUES (?, ?)";
  db.query(query, [image, subtext], (err, result) => {
    if (err) {
      console.error("Insert error:", err);
      return res.status(500).json({ message: "Error saving post." });
    }

    res.status(201).json({
      id: result.insertId,
      image: image,
      subtext: subtext,
      created_at: new Date(),
    });
  });
});



app.get("/api/posts", (req, res) => {
  db.query("SELECT * FROM posts ORDER BY created_at DESC", (err, results) => {
    if (err) return res.status(500).json({ message: "Error retrieving posts." });
    res.status(200).json(results);
  });
});



app.delete("/api/posts/:id", (req, res) => {
  const postId = req.params.id;

  db.query("SELECT image FROM posts WHERE id = ?", [postId], (err, results) => {
    if (err || results.length === 0)
      return res.status(404).json({ message: "Post not found" });

    const imageFile = results[0].image;

    db.query("DELETE FROM posts WHERE id = ?", [postId], (err) => {
      if (err) return res.status(500).json({ message: "Failed to delete post" });

      const imagePath = path.join(__dirname, "uploads", imageFile);
      fs.unlink(imagePath, (err) => {
        if (err && err.code !== 'ENOENT') {
          console.error("Error deleting image file:", err);
        }
      });

      res.status(200).json({ message: "Post deleted successfully" });
    });
  });
});


app.listen(PORT, HOST, () => {
  console.log(`Server running`);
});
