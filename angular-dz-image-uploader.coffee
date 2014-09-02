define ['angular'], (angular)->
#(->

  #angular.module('dz.uiimageuploader', [])
  angular.module('dz.uiimageuploader', ['ng-qiniu-uploader-tpl'])
  .directive 'dzLargeUploader', [()->

    {
      restrict: 'A'
      require: '^ngModel'
      replace: false
      templateUrl: 'large-uploader-tpl.html'
      #controllerAs: 'largeUploadCtrl'
      controller: ['$scope', ($scope)->

        $scope.startUploadBtnText = '开始上传'
        $scope.startUploadBtn = true
        $scope.remove = (index)->
          $scope.images.splice(index, 1)
          $scope.$emit('remove.image', index)
      ]
      # bind var
      scope:
        #keyRule: '&'
        #uptokenUrl: '='
        #domain: '='
        #limitSize: '='
        #thumbWidth: '='
        #thumbHeight: '='
        namespace: '@'
        options: '='

      link: (scope, element, attrs, ngModel)->
        # init scope
        scope.images = [];
        # init input[file]
        scope.accept = attrs.accept
        uploadedSize = 0 # 总共上传大小
        uploadedImages = [] #最终与模型同步的结果集
        selectFileNums = 0 # 总共选择的文件数量

        # init uploader
        uploader = Qiniu.uploader({
          runtimes: 'html5,flash,html4'
          browse_button: 'FileSelectBtn'
          container: 'UploadContainer'
          drop_element: 'UploadContainer'
          max_file_size: scope.options.limitSize
          flash_swf_url: 'js/plupload/Moxie.swf'
          dragdrop: true
          chunk_size: '4mb'
          max_retries: 3
          uptoken_url: scope.options.uptokenUrl
          domain: scope.options.domain
        # downtoken_url: '/downtoken'
          resize:
            width: scope.options.thumbWidth
            height: scope.options.thumbHeight
            quality: 80
            crop: false

          unique_names: false
          save_key: false
          auto_start: false

          'init':
            'FilesAdded': (up, files)->
              for file, index in files
                # create reader
                reader = new FileReader()
                # get base64
                reader.readAsDataURL(file.getNative())
                # load image
                reader.onload = (e)->
                  img = new Image()
                  img.src = e.target.result
                  img.id = file.id
                  img.removebtn = true
                  scope.$apply (_scope_)->
                    _scope_.images.push(img)

            'BeforeUpload': (up, file)->
              #console.log('BeforeUpload', file)
            'UploadProgress': (up, file)->
              percentage = parseInt(file.percent, 10) #上传百分比
              uploadedSize += file.loaded # 累加上传总和

              if (file.status is plupload.DONE and percentage is 100)
                percentage = 99

              # 进行 脏检查循环
              scope.$apply (_scope_)->
                _scope_.present = percentage  #上传百分比
                _scope_.uploadSize = plupload.formatSize(uploadedSize).toUpperCase(); #已经上传
                _scope_.speed = plupload.formatSize(up.total.bytesPerSec).toUpperCase()  # 上传速度 /s
              # 需要手动更新 样式的值
              element.find('div.progress>div.progress-bar').css({width: "#{percentage}%"})

            'UploadComplete': (up, files)->
              #最终将上传 后曾工的结果集更新到 model中
              #console.log('UploadComplete')
              scope.$apply (_scope_)->
                ngModel.$setViewValue(uploadedImages || [])
              # 更改上传 按钮 内容
              scope.$apply (_scope_)->
                _scope_.startUploadBtnText = "上传完成"
                _scope_.startUploadBtn = false  #禁用

            'FileUploaded': (up, file, res)->
              # 记录下所有，上传成功的，结果集
              # 消除所有上传成功的 cancel 按钮
              scope.images.forEach (img, i)->
                if file.id is img.id
                  scope.$apply (_scope_)->
                    img.removebtn = false
              try
                uploadedImages.push(JSON.parse(res).key)
              catch err
                console.log(err)
              #console.log('FileUploaded', res)
            'Error': (up, err, errTip)->
              console.log(up, err, errTip)

            'Key': scope.options.keyRule(scope.namespace) # (up, file)->

        })

        # 当删除某个图片的时候，将将该图片从uploader中移除
        scope.$on 'remove.image', (e, index)->
          uploader.splice(index, 1)

        # start uploading
        element.find('button.upload-btn').on 'click', (e)->
          uploader.start()
    }

  ]
#)()