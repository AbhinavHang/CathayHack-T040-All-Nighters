// server.js
const express = require('express')
const mongoose = require('mongoose')
const cors = require('cors')
require('dotenv').config()

const app = express()
const port = 3000

app.use(cors())
app.use(express.json())

// MongoDB Connection
mongoose
  .connect(process.env.MONGODB_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(() => {
    console.log('Connected to MongoDB')
  })
  .catch((err) => {
    console.error('MongoDB connection error:', err)
  })

// Schemas
const cargoSchema = new mongoose.Schema({
  awbNumber: { type: String, required: true, unique: true },
  origin: { type: String, required: true },
  destination: { type: String, required: true },
  weight: String,
  pieces: Number,
  shipper: String,
  consignee: String,
  specialHandling: [String],
  status: String,
  description: String,
  deadline: Date,
  timestamp: { type: Date, default: Date.now },
})

const Cargo = mongoose.model('Cargo', cargoSchema)

// Pre-populate database with sample data
async function populateDatabase() {
  try {
    const count = await Cargo.countDocuments()
    if (count === 0) {
      const sampleCargo = [
        {
          awbNumber: '160-12345678',
          origin: 'HKG',
          destination: 'LAX',
          weight: '245.5 KG',
          pieces: 3,
          shipper: 'ABC Electronics Ltd',
          consignee: 'XYZ Trading Co',
          specialHandling: ['PER', 'VUN'],
          status: 'Awaiting',
          description: 'Electronic Components',
          deadline: new Date(Date.now() + 3600000), // 1 hour from now
        },
        {
          awbNumber: '160-87654321',
          origin: 'PVG',
          destination: 'SIN',
          weight: '1,240 KG',
          pieces: 8,
          shipper: 'Global Tech Manufacturing',
          consignee: 'Singapore Electronics',
          specialHandling: ['DGR', 'CAO'],
          status: 'In Transit',
          description: 'Industrial Equipment',
          deadline: new Date(Date.now() + 7200000), // 2 hours from now
        },
      ]
      await Cargo.insertMany(sampleCargo)
      console.log('Sample data inserted')
    }
  } catch (error) {
    console.error('Error populating database:', error)
  }
}

populateDatabase()

// API Routes
// Get all cargo
app.get('/api/cargo', async (req, res) => {
  try {
    const cargo = await Cargo.find()
    res.json(cargo)
  } catch (error) {
    res.status(500).json({ message: error.message })
  }
})

// Get awaiting cargo (not scanned yet)
app.get('/api/cargo/awaiting', async (req, res) => {
  try {
    const cargo = await Cargo.find({ status: 'Awaiting' })
    res.json(cargo)
  } catch (error) {
    res.status(500).json({ message: error.message })
  }
})

// Get cargo by AWB number
app.get('/api/cargo/:awbNumber', async (req, res) => {
  try {
    const cargo = await Cargo.findOne({ awbNumber: req.params.awbNumber })
    if (cargo) {
      res.json(cargo)
    } else {
      res.status(404).json({ message: 'Cargo not found' })
    }
  } catch (error) {
    res.status(500).json({ message: error.message })
  }
})

// Update cargo status
app.put('/api/cargo/:awbNumber', async (req, res) => {
  try {
    const cargo = await Cargo.findOneAndUpdate(
      { awbNumber: req.params.awbNumber },
      { $set: req.body },
      { new: true }
    )
    if (cargo) {
      res.json(cargo)
    } else {
      res.status(404).json({ message: 'Cargo not found' })
    }
  } catch (error) {
    res.status(500).json({ message: error.message })
  }
})

// Add new cargo
app.post('/api/cargo', async (req, res) => {
  try {
    const cargo = new Cargo(req.body)
    const newCargo = await cargo.save()
    res.status(201).json(newCargo)
  } catch (error) {
    res.status(400).json({ message: error.message })
  }
})

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`)
})
