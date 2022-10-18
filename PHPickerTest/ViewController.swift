//
//  ViewController.swift
//  PHPickerTest
//
//  Created by 박재우 on 2022/10/14.
//

import UIKit
import PhotosUI

class ViewController: UIViewController {
    var myImageView: UIImageView!
    // 만든 날짜 혹은 장소에 대한 데이터 값으로 확인 개별적으로 추가를 해야하는 지 입력받기
    var location: CLLocationCoordinate2D?
    var creationDate: Date?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myImageView = UIImageView()
        myImageView.backgroundColor = .systemBackground
        myImageView.frame = CGRect(x: 10, y: 100, width: UIScreen.main.bounds.size.width - 100, height: UIScreen.main.bounds.size.width - 100)
        self.view.addSubview(myImageView)
        
        let addImageButton = addSymbolButton
        addImageButton.addTarget(self, action: #selector(pickerButton), for: .touchUpInside)
        self.view.addSubview(addImageButton)
    }
    
    var addSymbolButton: UIButton = {
        var button = UIButton(type: .system)
        let deviceSize = UIScreen.main.bounds.size
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold, scale: .large)
        let sfSymbol = UIImage(systemName: "plus.circle.fill", withConfiguration: largeConfig)
        button.setImage(sfSymbol, for: .normal)
        button.tintColor = .systemPink
        button.frame = CGRect(x: deviceSize.width - 60, y: deviceSize.height - 160, width: 50, height: 50)
        return button
    }()
    
    @objc func pickerButton(sender: UIButton!) {
        var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        // 유저가 선택할 수 있는 에셋의 최대 갯수
        configuration.selectionLimit = 1
        // picker 가 표시하는 에셋 타입 제한, .images, .livePhotos, .videos 혹은 아래 방법은 all
        // configuration.filter = .any(of: [.images, .livePhotos, .videos])
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
}

extension ViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // 선택완료 혹은 취소하면 뷰 dismiss
        picker.dismiss(animated: true, completion: nil)

        // 사진 여러 장일 경우 results[1], [2] ...
        if let assetId = results[0].assetIdentifier {
            let assetResults = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil)
            DispatchQueue.main.async {
                print(assetResults.firstObject?.creationDate ?? "만든 날짜를 모르겠습니다")
                if let coordinate = assetResults.firstObject?.location?.coordinate {
                    print(coordinate)
                } else {
                    print("여기가 어딘지 모르겠습니다")
                }
            }
        }
        
           // itemProvider 에서 지정한 타입으로 로드할 수 있는지 체크
        if results[0].itemProvider.canLoadObject(ofClass: UIImage.self) {
            // loadObject() 메서드는 completionHandler 로 NSItemProviderReading 과 error 를 준다.
            results[0].itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                DispatchQueue.main.async {
                    self.myImageView.image = image as? UIImage
                }
            }
        }
    }
}
