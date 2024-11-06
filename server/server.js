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

// Enhanced Schema with validation
const cargoSchema = new mongoose.Schema({
  awbNumber: {
    type: String,
    required: true,
    unique: true,
    validate: {
      validator: function (v) {
        return /^\d{3}-\d{8}$/.test(v)
      },
      message: (props) =>
        `${props.value} is not a valid AWB number! Format should be XXX-XXXXXXXX`,
    },
  },
  origin: {
    type: String,
    required: true,
    minlength: 3,
    maxlength: 3,
    uppercase: true,
  },
  destination: {
    type: String,
    required: true,
    minlength: 3,
    maxlength: 3,
    uppercase: true,
  },
  weight: String,
  pieces: {
    type: Number,
    min: 1,
    required: true,
  },
  shipper: String,
  consignee: String,
  specialHandling: [String],
  status: {
    type: String,
    enum: ['Awaiting', 'In Progress', 'Done', 'Cancelled'],
    default: 'Awaiting',
  },
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

// Enhanced POST endpoint with validation
app.post('/api/cargo', async (req, res) => {
  try {
    // Basic validation
    const requiredFields = ['awbNumber', 'origin', 'destination', 'pieces']
    for (const field of requiredFields) {
      if (!req.body[field]) {
        return res.status(400).json({ message: `${field} is required` })
      }
    }

    // AWB number format validation
    if (!/^\d{3}-\d{8}$/.test(req.body.awbNumber)) {
      return res.status(400).json({
        message: 'Invalid AWB number format. Should be XXX-XXXXXXXX',
      })
    }

    // Airport code validation
    if (req.body.origin.length !== 3 || req.body.destination.length !== 3) {
      return res.status(400).json({
        message: 'Origin and destination must be 3-letter airport codes',
      })
    }

    // Create and save the cargo
    const cargo = new Cargo(req.body)
    const newCargo = await cargo.save()
    res.status(201).json(newCargo)
  } catch (error) {
    if (error.code === 11000) {
      res.status(400).json({ message: 'AWB number already exists' })
    } else {
      res.status(400).json({ message: error.message })
    }
  }
})

// Bulk insert endpoint (for testing)
app.post('/api/cargo/bulk', async (req, res) => {
  try {
    const cargos = req.body
    if (!Array.isArray(cargos)) {
      return res.status(400).json({ message: 'Request body must be an array' })
    }

    const result = await Cargo.insertMany(cargos, { ordered: false })
    res.status(201).json(result)
  } catch (error) {
    res.status(400).json({ message: error.message })
  }
})

app.get('/api/cargo/awaiting', async (req, res) => {
  try {
    const cargo = await Cargo.find({ status: 'Awaiting' })
    res.json(cargo)
  } catch (error) {
    res.status(500).json({ message: error.message })
  }
})

app.get('/api/cargo/history', async (req, res) => {
  try {
    const cargo = await Cargo.find({ status: 'Done' })
    res.json(cargo)
  } catch (error) {
    res.status(500).json({ message: error.message })
  }
})

// Get cargo by status
app.get('/api/cargo/status/:status', async (req, res) => {
  try {
    const cargo = await Cargo.find({ status: req.params.status })
    res.json(cargo)
  } catch (error) {
    res.status(500).json({ message: error.message })
  }
})

app.get('/api/cargo/awb/:awbNumber', async (req, res) => {
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

// Search cargo by various criteria
app.get('/api/cargo/search', async (req, res) => {
  try {
    const query = {}
    if (req.query.origin) query.origin = req.query.origin.toUpperCase()
    if (req.query.destination)
      query.destination = req.query.destination.toUpperCase()
    if (req.query.status) query.status = req.query.status
    if (req.query.specialHandling) {
      query.specialHandling = { $in: [req.query.specialHandling] }
    }

    const cargo = await Cargo.find(query)
    res.json(cargo)
  } catch (error) {
    res.status(500).json({ message: error.message })
  }
})

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`)
})
