const express = require('express');
const cors = require('cors');
const app = express();
const port = 3000;

app.use(cors());

app.get('/data', (req, res) => {
  res.send('Hello from Node.js backend!');
});

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
