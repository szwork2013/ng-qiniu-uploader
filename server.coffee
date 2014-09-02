express = require 'express'
qiniu = require 'qiniu'

qiniu.conf.ACCESS_KEY = 'Wzgrm_rKsinUhBDk1YzyIKFsmCK9M_4Y8rcbjeeb'
qiniu.conf.SECRET_KEY = 'KjxD2tp6WOhrFzCbWIDSGACBe6TC7ppDI54sOVHt'

app = express()

app.use express.static(__dirname)

app.get '/uptoken', (req, res)->
  uptoken = new qiniu.rs.PutPolicy('dongzone-test1')
  res.json({ uptoken: uptoken.token() })

app.listen(8000)
