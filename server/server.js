const express = require('express')
const mongoose = require('mongoose')
const cors = require('cors')
require('dotenv').config()

const app = express()
const port = process.env.PORT || 3000

// Enhanced CORS configuration
app.use(
  cors({
    origin: '*', // Update this with your frontend domain in production
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  })
)

app.use(express.json())

// MongoDB Connection with enhanced error handling
mongoose
  .connect('mongodb+srv://admin:admin@cluster0.nlek8.mongodb.net/', {
    useNewUrlParser: true,
    useUnifiedTopology: true,
    serverSelectionTimeoutMS: 5000,
    socketTimeoutMS: 45000,
  })
  .then(() => {
    console.log('Connected to MongoDB')
  })
  .catch((err) => {
    console.error('MongoDB connection error:', err)
  })

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV,
  })
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

// Database initialization with sample data
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
          deadline: new Date(Date.now() + 3600000),
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
          status: 'In Progress',
          description: 'Industrial Equipment',
          deadline: new Date(Date.now() + 7200000),
        },
        {
          awbNumber: '160-11112222',
          origin: 'NRT',
          destination: 'ICN',
          weight: '850 KG',
          pieces: 5,
          shipper: 'Tokyo Electronics',
          consignee: 'Seoul Distributors',
          specialHandling: ['PER'],
          status: 'Done',
          description: 'Consumer Electronics',
          deadline: new Date(Date.now() - 3600000),
        },
      ]
      await Cargo.insertMany(sampleCargo)
      console.log('Sample data inserted')
    }
  } catch (error) {
    console.error('Error populating database:', error)
  }
}

// Initialize database
populateDatabase()

// API Routes with error handling
// Get all cargo
app.get('/api/cargo', async (req, res) => {
  try {
    const cargo = await Cargo.find()
    res.json(cargo)
  } catch (error) {
    console.error('Error fetching all cargo:', error)
    res.status(500).json({ message: error.message })
  }
})

// Get awaiting cargo
app.get('/api/cargo/awaiting', async (req, res) => {
  try {
    const cargo = await Cargo.find({ status: 'Awaiting' })
    res.json(cargo)
  } catch (error) {
    console.error('Error fetching awaiting cargo:', error)
    res.status(500).json({ message: error.message })
  }
})

// Get cargo history
app.get('/api/cargo/history', async (req, res) => {
  try {
    const cargo = await Cargo.find({ status: 'Done' })
    res.json(cargo)
  } catch (error) {
    console.error('Error fetching cargo history:', error)
    res.status(500).json({ message: error.message })
  }
})

// Get cargo by AWB
app.get('/api/cargo/awb/:awbNumber', async (req, res) => {
  try {
    const cargo = await Cargo.findOne({ awbNumber: req.params.awbNumber })
    if (cargo) {
      res.json(cargo)
    } else {
      res.status(404).json({ message: 'Cargo not found' })
    }
  } catch (error) {
    console.error('Error fetching cargo by AWB:', error)
    res.status(500).json({ message: error.message })
  }
})

// Get cargo by status
app.get('/api/cargo/status/:status', async (req, res) => {
  try {
    const cargo = await Cargo.find({ status: req.params.status })
    res.json(cargo)
  } catch (error) {
    console.error('Error fetching cargo by status:', error)
    res.status(500).json({ message: error.message })
  }
})

// Search cargo
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
    console.error('Error searching cargo:', error)
    res.status(500).json({ message: error.message })
  }
})

// Create new cargo
app.post('/api/cargo', async (req, res) => {
  try {
    // Validation
    const requiredFields = ['awbNumber', 'origin', 'destination', 'pieces']
    for (const field of requiredFields) {
      if (!req.body[field]) {
        return res.status(400).json({ message: `${field} is required` })
      }
    }

    if (!/^\d{3}-\d{8}$/.test(req.body.awbNumber)) {
      return res.status(400).json({
        message: 'Invalid AWB number format. Should be XXX-XXXXXXXX',
      })
    }

    if (req.body.origin.length !== 3 || req.body.destination.length !== 3) {
      return res.status(400).json({
        message: 'Origin and destination must be 3-letter airport codes',
      })
    }

    const cargo = new Cargo(req.body)
    const newCargo = await cargo.save()
    res.status(201).json(newCargo)
  } catch (error) {
    console.error('Error creating cargo:', error)
    if (error.code === 11000) {
      res.status(400).json({ message: 'AWB number already exists' })
    } else {
      res.status(400).json({ message: error.message })
    }
  }
})

// Update cargo status
app.put('/api/cargo/:awbNumber', async (req, res) => {
  try {
    const cargo = await Cargo.findOneAndUpdate(
      { awbNumber: req.params.awbNumber },
      { $set: req.body },
      { new: true, runValidators: true }
    )
    if (cargo) {
      res.json(cargo)
    } else {
      res.status(404).json({ message: 'Cargo not found' })
    }
  } catch (error) {
    console.error('Error updating cargo:', error)
    res.status(400).json({ message: error.message })
  }
})

// Bulk insert (for testing)
app.post('/api/cargo/bulk', async (req, res) => {
  try {
    if (!Array.isArray(req.body)) {
      return res.status(400).json({ message: 'Request body must be an array' })
    }
    const result = await Cargo.insertMany(req.body, { ordered: false })
    res.status(201).json(result)
  } catch (error) {
    console.error('Error bulk inserting cargo:', error)
    res.status(400).json({ message: error.message })
  }
})

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack)
  res.status(500).json({
    message: 'Something broke!',
    error:
      process.env.NODE_ENV === 'development'
        ? err.message
        : 'Internal server error',
  })
})

// 404 handler
app.use((req, res) => {
  res.status(404).json({ message: 'Route not found' })
})

// Start server if not in production (Vercel)
if (process.env.NODE_ENV !== 'production') {
  app.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`)
  })
}

module.exports = app
