cookie usercookie: {Id: int}

sequence userIds
sequence questionIds
sequence answerIds

table users: {Id: int, Username: option string, Email: option string}
		 PRIMARY KEY Id
	     
table questions: {Id: int, Question: string, Answer: string, AuthorId: option int}
		     PRIMARY KEY Id,
      (*CONSTRAINT confk FOREIGN KEY AuthorId REFERNECES users(Id)*)


table answers: {Id: int, QuestionId: int, UserId: int, Answer: string, Confidence: string}
(*table predictions: {Id: int, Text: string, Confidence: string}*)

(*Answers can be:
    a range of numbers
    (later) a list of strings
    (later) a minimum number
    (later) a maximum number
    (later) a single string *)
	       
(* TODO: write result datatype so that questions can have string
results as well, or float results*)

(* To-do list:
   - When query submitted, we should set a cookie
   - Ajaxify everything.
   - Grading and storing data when user answers question
   - Display shiny homepage stats
   - Display shiny calibration graph
   - More nuanced question types and result types
   - Friends features -- add friend requests, see how friends are doing, see friend requests
   - Allow people to submit their own predictions 
   - Gravatar features
   - Points features
   - ...badges? o_O
*)
	       
(* Sequences: for changing ids*)

(* Tasks: for code done on initialization*)
(* task initialize = ((some function from unit to transaction unit)) *)
(* also note clientLeaves -- useful for chat clients *)


task initialize =
 fn () =>
    dml (INSERT INTO questions (Id, Question, Answer, AuthorId)
	 VALUES (1, "Is mayonnaise an instrument?", "No", {[None]}));
    dml (INSERT INTO questions (Id, Question, Answer, AuthorId)
	 VALUES (1, "How old is Barack Obama?", "53", {[None]}));
    dml (INSERT INTO questions (Id, Question, Answer, AuthorId)
	 VALUES (1, "How many milliliters in a liter?", "1000", {[None]}));
    return ()

(* Non-page-returning helper functions *)

fun newAnonUser () : transaction int =
    (* Note: Should return an int for the unique user ID *)
    userId <- nextval userIds;
    dml (INSERT INTO users (Id, Username, Email)
	 VALUES ({[userId]}, {[None]}, {[None]}));
    return userId



fun foreignKey id db =
    




		
(* Page-returning functions *)
		    
fun main () =
    (* Todo: Only pick from those questions the user hasn't answered yet. *)
    question_links <- queryX (SELECT * FROM questions)
		 (fn row => <xml><p><a link={question row.Questions.Id}>{[row.Questions.Question]}</a></p></xml>);
    answered_by_user <- queryX (SELECT * FROM answers)
		 (fn row => <xml><p>answered {[row.Answers.Answer]} at {[row.Answers.Confidence]}% confidence</p></xml>);
    (*answered_by_user <- queryX (SELECT * FROM answers)
                 (fn row => *)
    return <xml>
      <head><title>Main</title></head><body>
	<h1>Hello, world!</h1>
	<p><a link={settings ""}>Settings</a></p>
	<h2>Make predictions</h2>
	{question_links}
	<h2>Already answered:</h2>
	{answered_by_user}
    </body></xml>

and settings cookiemsg =
    (* cookiemsg :: Maybe string *)
    return <xml>
      <head><title>Settings</title></head><body>
	<p>Manage your settings here.</p>
	<i>{[cookiemsg]}</i>
	<form>
	  <submit action={maybeSetCookie} value="Remember me on this computer (with a cookie)"/>
	</form>
	<form>
	  <submit action={maybeDeleteCookie} value="Delete my cookie"/>
	</form>
	<p><a link={main ()}>Return to main menu</a></p>
      </body></xml>

(* Todo: If the user has already answered the question, show here instead a shiny page with their previous answers, and maybe their friends' answers later.*)
and question questionId = 
    questionText <- return "TODO";
    return <xml>
      <head><title>Question: {[questionText]}</title></head><body>
	<p>Current question: {[questionText]}</p>
	<form>
	  <p>Your answer: <textbox{#Answer}/></p>
	  <p>Your confidence: <textbox{#Confidence}/></p>
	  <p><submit action={answerHandler questionId}/></p>
	</form>
	<p><a link={main ()}>Return to main menu</a></p>
    </body></xml>

and answerHandler questionId r =
    (*table answers: {Id: int, QuestionId: int, UserId: int, AnswerMin: int, AnswerMax: int, Confidence: float}*)
    answerId <- nextval answerIds;
    userId <- return 42; (*TODO*)
    questionText <- return "TODO";
    dml (INSERT INTO answers (Id, QuestionId, UserId, Answer, Confidence)
	 VALUES ({[answerId]}, {[questionId]}, {[userId]}, {[r.Answer]}, {[r.Confidence]}));
    return <xml>
      <head><title>Answer: {[questionText]}</title></head><body>
	<p>Current question: {[questionText]}</p>
	<p>You answered {[r.Answer]} with {[r.Confidence]}% confidence.</p>
	<p>The correct answer is TODO.</p>
	<p><a link={main ()}>Return to main menu</a></p>
    </body></xml>

and maybeSetCookie unused =
    uc <- getCookie usercookie;
    case uc of
	None =>
	uid <- newAnonUser ();
	setCookie usercookie {Value = {Id = uid},
			      Expires = None,
			      Secure = False};
	settings "Cookie set!"
      | Some uid => settings "Cookie was already set."

and maybeDeleteCookie unused =
    clearCookie usercookie;
    settings "Cookie deleted!"

