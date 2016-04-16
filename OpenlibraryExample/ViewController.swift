//
//  ViewController.swift
//  OpenlibraryExample
//
//  Created by Ivan Duran Martinez on 6/4/16.
//  Copyright © 2016 Indenext. All rights reserved.
//

// Coursera. Curso: "Accediendo a la nube con iOS". Instituto tecnológico de Monterrey.
// Tarea Semana 1. Petición al servidor openlibrary.org


//Instrucciones
//
//En este entregable desarrollarás una aplicación usando Xcode que realice una petición a https://openlibrary.org/
//
//Para ello deberás crear una interfaz de usuario, usando la herramienta Storyboard que contenga:
//
//Una caja de texto para capturar el ISBN del libro a buscar
//EL botón de "enter" del teclado del dispositivo deberá ser del tipo de búsqueda ("Search")
//El botón de limpiar ("clear") deberá estar siempre presente
//Una vista texto (Text View) para mostrar el resultado de la petición
//Un ejemplo de URL para acceder a un libro es:
//
// https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:978-84-376-0494-7
//
//Su programa deberá sustituir el último código de la URL anterior (en este caso 978-84-376-0494-7) por lo que se ponga en la caja de texto
//
//Al momento de presionar buscar en el teclado, se deberá mostrar los datos crudos (sin procesar) producto de la consulta en la vista texto en concordancia con el ISBN que se ingreso en la caja de texto
//
//En caso de error (problemas con Internet), se deberá mostrar una alerta indicando esta situación
//
//Sube tu solución a GitHub e ingresa la URL en el campo correspondiente



import UIKit

class ViewController: UIViewController {
    let baseURL = "https://openlibrary.org"
    let responseFormat = "json"

    @IBOutlet weak var isbnTextfield: UITextField!
    @IBOutlet weak var resultTextView: UITextView!
    @IBOutlet weak var cover: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func search(){
        
        let urlStr = baseURL + "/api/books?jscmd=data&format=" + responseFormat + "&bibkeys=" + isbnTextfield.text!
        
        // En caso de error, informar al usuario.
        if let url = NSURL(string: urlStr), let datos:NSData = NSData(contentsOfURL: url){
//            let texto = NSString(data: datos!, encoding: NSUTF8StringEncoding)
//            resultTextView.text = (texto! as String)
            
            do{
                let json = try NSJSONSerialization.JSONObjectWithData(datos, options: .MutableLeaves)
                let dico = json as! NSDictionary
                
                if dico.count == 0 {
                    cover.image = nil
                    resultTextView.text = "No se puede encontrar el libro"
                    return
                }
                
                let isbn = isbnTextfield.text! as NSString
                let libro = dico[isbn] as! NSDictionary
                let result = libro["title"] as! String
                var message = "Titulo: \(result)\n"
                let autores = libro["authors"] as! NSArray
                if autores.count > 1{
                    message += "Autores:\n"
                    for autor in autores{
                        message += "\t\(autor["name"])"
                    }
                }else if autores.count == 1{
                    let nombre = autores.firstObject!["name"] as! NSString
                    message += "Autor: \(nombre)"
                }
                
                resultTextView.text = message
                let imageURL = NSURL(string: "http://covers.openlibrary.org/b/isbn/\(isbn)-L.jpg")!
                let image = NSData(contentsOfURL: imageURL)!
                cover.image = UIImage(data: image)
                
            }catch _{
                
            }
        }else{
            let message = "Parece que hay algún problema con la conexión."
            resultTextView.text = message
            let alert = UIAlertController(title: "Alerta", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Cerrar", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func textFieldReturn(sender: AnyObject) {
        self.resignFirstResponder()
        
        guard isbnTextfield.text!.characters.count > 0 else {
            return
        }
        search()
    }
}

