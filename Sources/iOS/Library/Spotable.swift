import UIKit

public protocol Spotable: class {

  static var views: [String : UIView.Type] { get set }
  static var defaultView: UIView.Type { get set }

  weak var spotsDelegate: SpotsDelegate? { get set }

  var index: Int { get set }
  var component: Component { get set }

  init(component: Component)

  func setup(size: CGSize)
  func append(item: ViewModel, completion: (() -> Void)?)
  func append(items: [ViewModel], completion: (() -> Void)?)
  func prepend(items: [ViewModel], completion: (() -> Void)?)
  func insert(item: ViewModel, index: Int, completion: (() -> Void)?)
  func update(item: ViewModel, index: Int, completion: (() -> Void)?)
  func delete(index: Int, completion: (() -> Void)?)
  func delete(indexes: [Int], completion: (() -> Void)?)
  func reload(indexes: [Int]?, completion: (() -> Void)?)
  func render() -> UIScrollView
  func layout(size: CGSize)
  func prepare()
  func scrollTo(@noescape includeElement: (ViewModel) -> Bool) -> CGFloat
}

public extension Spotable {

  var items: [ViewModel] {
    set(items) {
      component.items = items
    }
    get {
      return component.items
    }
  }

  public func item(index: Int) -> ViewModel {
    return component.items[index]
  }

  public func item(indexPath: NSIndexPath) -> ViewModel {
    return component.items[indexPath.item]
  }

  public func spotHeight() -> CGFloat {
    return component.items.reduce(0, combine: { $0 + $1.size.height })
  }

  public func refreshIndexes() {
    items.enumerate().forEach {
      items[$0.index].index = $0.index
    }
  }

  public func scrollTo(@noescape includeElement: (ViewModel) -> Bool) -> CGFloat {
    return 0.0
  }

  public func prepareItem<T: Spotable>(item: ViewModel, index: Int, spot: T, inout cached: UIView?) {
    let reuseIdentifer = item.kind.isEmpty ? component.kind : item.kind
    let componentClass = T.views[reuseIdentifer] ?? T.defaultView

    component.items[index].index = index

    if cached?.isKindOfClass(componentClass) == false { cached = nil }
    if cached == nil { cached = componentClass.init() }

    (cached as? ViewConfigurable)?.configure(&component.items[index])
  }
}
