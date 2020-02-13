const express = require('express')

const app = express()

app.get('/', (_, res) => {
  res.send('Hello, World!')
})

const port = process.env.PORT || 3000
const server = app.listen(port, () => {
  console.log('listening on port %s.\n', server.address().port)
})

module.exports = app
