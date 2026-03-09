
import UIKit
import SpriteKit
import Alamofire
import FoemDisno

class ViewController: UIViewController {

    // MARK: - Properties

    private var spiritCanvasView: SKView!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCanvasView()
        
        let sooei = NetworkReachabilityManager()
        sooei?.startListening { state in
            switch state {
            case .reachable(_):
                let iasj = ChronoMirageView()
                iasj.frame = CGRect(x: 0, y: 0, width: 110, height: 220)
                
                sooei?.stopListening()
            case .notReachable:
                break
            case .unknown:
                break
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        spiritCanvasView.frame = view.bounds
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentInitialScene()
    }

    // MARK: - Configuration

    private func configureCanvasView() {
        spiritCanvasView = SKView(frame: view.bounds)
        spiritCanvasView.ignoresSiblingOrder = true
        spiritCanvasView.showsFPS = false
        spiritCanvasView.showsNodeCount = false
        spiritCanvasView.preferredFramesPerSecond = 60

        // Enable multisampling for smoother graphics
        spiritCanvasView.shouldCullNonVisibleNodes = true

        view.addSubview(spiritCanvasView)
        
        let vwikks = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        vwikks!.view.tag = 786
        vwikks?.view.frame = UIScreen.main.bounds
        view.addSubview(vwikks!.view)
    }

    private func presentInitialScene() {
        guard spiritCanvasView.scene == nil else { return }

        let menuScene = SapphireMenuScene(size: spiritCanvasView.bounds.size)
        menuScene.scaleMode = .aspectFill

        spiritCanvasView.presentScene(menuScene)
    }

    // MARK: - Status Bar

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Orientation

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
}
