const ORIGIN = '*'
const PORT = process.env.PORT || 8080

// for "atlas" edit MONGO_URI in -> .env file || for "community server" edit <MyDatabase> mongodb://localhost:27017/MyDatabase unsafe_secret
const MONGO_URI = process.env.MONGO_URI || ''
const MONGO_OPTIONS = {}

const JWT_SECRET = process.env.JWT_SECRET || ''

module.exports = {
  ORIGIN,
  PORT,
  MONGO_URI,
  MONGO_OPTIONS,
  JWT_SECRET,
}
