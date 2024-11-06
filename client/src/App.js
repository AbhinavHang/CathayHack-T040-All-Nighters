import { useState } from 'react'

export default function App() {
  const [image, setImage] = useState(null)

  const handleImageUpload = (event) => {
    const file = event.target.files[0]
    if (file) {
      const reader = new FileReader()
      reader.onloadend = () => {
        setImage(reader.result)
      }
      reader.readAsDataURL(file)
    }
  }

  return (
    <div className='App'>
      <div className='container'>
        <div className='upload-box'>
          <input type='file' accept='image/*' onChange={handleImageUpload} />
        </div>
        <div className='image-box'>
          {image && <img src={image} alt='Uploaded' />}
        </div>
      </div>
    </div>
  )
}