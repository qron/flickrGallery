import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var removeTagsBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var tagTextField: UITextField!
    @IBOutlet weak var tagsListTextView: UITextView!
    
    var tags: [String] = []
    
    @IBAction func onTapGesture(_ sender: UITapGestureRecognizer) {
        tagTextField.resignFirstResponder()
    }
    
    @IBAction func onAddButtonTapAction(_ sender: Any) {
        
        if (tagTextField.text?.isEmpty) != true {
            
            tags.append(tagTextField.text!)
            
            if tags.count == 1 {
                tagsListTextView.text! = tagTextField.text!
            } else {
                tagsListTextView.text! += ", \(tagTextField.text!)"
            }
            tagTextField.text = ""
            
            searchBarButtonItem.isEnabled = true
            removeTagsBarButtonItem.isEnabled = true
            
        }
        
        tagTextField.resignFirstResponder()
    }
    
    @IBAction func onRemoveTagsTapAction(_ sender: Any) {
        tags = []
        tagsListTextView.text = ""
        searchBarButtonItem.isEnabled = false
        removeTagsBarButtonItem.isEnabled = false
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "galleryShowSegue" {
            
            let galleryCollectionViewController = segue.destination as! GalleryCollectionViewController
            
            if tags.count < 1 {
                tags.append("cat")
                tagsListTextView.text! = "cat"
            }
            
            galleryCollectionViewController.tags = tags
            
        }
        
    }

}
